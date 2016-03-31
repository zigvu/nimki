require 'json'
require 'fileutils'

module Khajuri
  class FileManager
    attr_reader :baseFolder, :clipFolder, :resultsFolder
    attr_reader :testInputPath, :modelPath

    def initialize(khajuriDetails, samosaClient, storageClient, isFakeGPU = false)
      @khajuriDetails = khajuriDetails
      @samosaClient = samosaClient
      @storageClient = storageClient
      @isFakeGPU = isFakeGPU
      @samosaPyRoot = "/home/ubuntu/samosa"

      # paths
      @baseFolder = "#{@khajuriDetails.baseFolder}/#{@khajuriDetails.capEvalId}"
      @clipFolder = "#{@baseFolder}/clips"
      FileUtils.mkdir_p(@clipFolder)
      @resultsFolder = "#{@baseFolder}/results"
      FileUtils.mkdir_p(@resultsFolder)
      @testInputPath = "#{@baseFolder}/#{File.basename(@khajuriDetails.testInputPath)}"
      @modelPath = "#{@baseFolder}/#{File.basename(@khajuriDetails.modelPath)}"
    end

    def getKhajuriInputFiles
      status, _ = @storageClient.getFile(@khajuriDetails.testInputPath, @testInputPath)
      return status if not status

      status, _ = @storageClient.getFile(@khajuriDetails.modelPath, @modelPath)
      return status if not status

      status
    end

    def untarBuildInput
      status = true
      Dir.chdir(File.dirname(@testInputPath)) do
        status = system("tar -zxvf #{@testInputPath}")
      end
      status
    end

    def getClipIds
      @khajuriDetails.clipIds
    end

    def downloadClip(clipId)
      status, message = @samosaClient.getClipDetails(clipId)
      if status
        # TODO: use message.storageHostname
        localClipPath = "#{@clipFolder}/#{File.basename(message.storageClipPath)}"
        status, message = @storageClient.getFile(message.storageClipPath, localClipPath)
        if status
          message = Messaging::Messages::Samosa::ClipEvalDetails.new({
            capEvalId: @khajuriDetails.capEvalId,
            clipId: clipId,
            localClipPath: localClipPath,
            state: Messaging::States::Samosa::ClipEvalStates.downloaded
          })
          status, message = @samosaClient.updateClipEval(message)
        end
      end
      if !status
        message = Messaging::Messages::Samosa::ClipEvalDetails.new({
          capEvalId: @khajuriDetails.capEvalId,
          clipId: clipId,
          state: Messaging::States::Samosa::ClipEvalStates.failed,
          trace: "Could not get clip details"
        })
        status, message = @samosaClient.updateClipEval(message)
      end
      return status, message
    end

    def uploadResult(message)
      message.localResultPath = "#{@resultsFolder}/#{message.clipId}.json"
      if @isFakeGPU
        File.open(message.localResultPath, "w") do |f|
          f.write(JSON.pretty_generate({
            meta: {clip_id: message.clipId, scale: 1.0, chia_model_id: @khajuriDetails.chiaModelId},
            data: {}
          }))
        end
      end

      # TODO: use message.storageHostname
      status, _ = @storageClient.saveFile(message.localResultPath, message.storageResultPath)
      if status
        message.state = Messaging::States::Samosa::ClipEvalStates.evaluated
      else
        message.state = Messaging::States::Samosa::ClipEvalStates.failed
        message.trace = "Could not save result file"
      end
      @samosaClient.updateClipEval(message)

      # FileUtils.rm_rf(message.localClipPath)
      # FileUtils.rm_rf(message.localResultPath)
      return status, message
    end

    def runKhajuriProcess
      status = true
      evalClipsBin = "#{@samosaPyRoot}/khajuri/bin/evaluate_clips.py"
      configFile = "#{@testInputPath}/zigvu_config_test.json"
      clipFolder = '/etc' # where we don't expect mp4 files
      cmd = "#{evalClipsBin} --config_file #{configFile} --test_model #{@modelPath} --clip_folder #{clipFolder} --output_path #{@resultsFolder}"
      if @isFakeGPU
      else
        status = system(cmd)
      end
      status
    end

    def updateState(state, progress)
      @samosaClient.updateKhajuriState(@khajuriDetails.capEvalId, state, progress)
    end
  end
end
