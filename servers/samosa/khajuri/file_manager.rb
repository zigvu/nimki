require 'json'
require 'fileutils'

module Khajuri
  class FileManager
    # for debug
    attr_reader :baseFolder, :clipFolder
    attr_reader :testInputPath, :modelPath

    def initialize(khajuriDetails, samosaClient, storageClient)
      @khajuriDetails = khajuriDetails
      @samosaClient = samosaClient
      @storageClient = storageClient
      @samosaPyRoot = "/home/ubuntu/samosa"

      @baseFolder = "#{@khajuriDetails.baseFolder}/#{@khajuriDetails.capEvalId}"
      @clipFolder = "#{@baseFolder}/clips"
      FileUtils.mkdir_p(@clipFolder)
    end

    def getKhajuriInputFiles
      @testInputPath = "#{@baseFolder}/#{File.basename(@khajuriDetails.testInputPath)}"
      status, _ = @storageClient.getFile(@khajuriDetails.testInputPath, @testInputPath)
      return status if not status

      @modelPath = "#{@baseFolder}/#{File.basename(@khajuriDetails.modelPath)}"
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
      clipIds = []
      File.open("#{File.dirname(@testInputPath)}/clip_ids.json", "r") do |f|
        clipIds = JSON.load(f)
      end
      clipIds.map{ |cl| cl.to_i }
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
          @samosaClient.updateClipEval(message)
        end
      end
      if !status
        message = Messaging::Messages::Samosa::ClipEvalDetails.new({
          capEvalId: @khajuriDetails.capEvalId,
          clipId: clipId,
          state: Messaging::States::Samosa::ClipEvalStates.failed,
          trace: "Could not get clip details"
        })
        @samosaClient.updateClipEval(message)
      end
      return status, message
    end

    def uploadResult(message)
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

  end
end
