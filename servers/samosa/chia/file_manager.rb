require 'json'
require 'fileutils'

module Chia
  class FileManager
    attr_reader :baseFolder, :buildInputPath, :parentModelPath
    attr_reader :clipIdsMap, :clipFolder
    attr_reader :buildDataBaseFolder, :modelBuildPath

    def initialize(chiaDetails, samosaClient, storageClient)
      @chiaDetails = chiaDetails
      @samosaClient = samosaClient
      @storageClient = storageClient
      @samosaPyRoot = "/home/ubuntu/samosa"

      # paths
      @baseFolder = "#{@chiaDetails.baseFolder}/#{@chiaDetails.iterationId}"
      FileUtils.mkdir_p(@baseFolder)
      @buildInputPath = "#{@baseFolder}/#{File.basename(@chiaDetails.buildInputPath)}"
      @parentModelPath = "#{@baseFolder}/#{File.basename(@chiaDetails.parentModelPath)}"
      @clipFolder = "#{@baseFolder}/clips"
      FileUtils.mkdir_p(@clipFolder)
      @buildDataBaseFolder = "#{@baseFolder}/build_data" # will be made by untarBuildInput
      # TODO: change
      @modelBuildPath = "#{File.dirname(@buildInputPath)}/clip_ids.json"
    end

    def getChiaBuildFiles
      status, _ = @storageClient.getFile(@chiaDetails.buildInputPath, @buildInputPath)
      return status if not status

      status, _ = @storageClient.getFile(@chiaDetails.parentModelPath, @parentModelPath)
      return status if not status

      status
    end

    def untarBuildInput
      status = true
      Dir.chdir(File.dirname(@buildInputPath)) do
        status = system("tar -zxvf #{@buildInputPath}")
      end
      status
    end

    def downloadClips
      @clipIdsMap = {}
      clipIds = []
      File.open("#{File.dirname(@buildInputPath)}/clip_ids.json", "r") do |f|
        clipIds = JSON.load(f)
      end
      status = true
      clipIds.each do |clipId|
        return status if not status
        status, message = @samosaClient.getClipDetails(clipId)
        # TODO: use message.storageHostname
        localClipPath = "#{@clipFolder}/#{File.basename(message.storageClipPath)}"
        @storageClient.getFile(message.storageClipPath, localClipPath)
        @clipIdsMap[clipId] = localClipPath
      end
      status
    end

    def extractFrames
      status = true
      frameExtractorBin = "#{@samosaPyRoot}/tools/bin/extract_frames_from_video.py"
      @clipIdsMap.each do |clipId, clipPath|
        return status if not status
        frameNumberFilePath = "#{@buildDataBaseFolder}/#{clipId}/frame_numbers.txt"
        framesOutBaseFolder = "#{@buildDataBaseFolder}/#{clipId}"
        status = system("#{frameExtractorBin} --video_path #{clipPath} --frame_numbers #{frameNumberFilePath} --output_path #{framesOutBaseFolder}")
      end
      status
    end

    def fineTuneCaffe
      status = true
      fineTunerBin = "#{@samosaPyRoot}/chia/bin/zigvu/train_local_dataset.py"
      configFile = "#{File.dirname(@buildInputPath)}/zigvu_config_train.json"
      status = system("#{fineTunerBin} --config_file #{configFile} --parent_model #{@parentModelPath} --annotation_folder #{@buildDataBaseFolder} --frame_folder #{@buildDataBaseFolder}")
      status
    end

    def saveBuiltModel
      status, message = @samosaClient.getChiaDetails(@chiaDetails.iterationId, @modelBuildPath)
      return status if not status

      # TODO: use message.storageHostname
      status, _ = @storageClient.saveFile(@modelBuildPath, message.storageModelPath)
      return status if not status

      status
    end
  end
end
