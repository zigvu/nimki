module Chia
  class BuildManager
    attr_accessor :fileManager

    def initialize(samosaState)
      @samosaState = samosaState
      @fileManager = Chia::FileManager.new(
        @samosaState.chiaDetails, @samosaState.samosaClient, @samosaState.storageClient
      )
    end

    def run
      status = true
      status = downloadFiles if status
      status = extractFrames if status
      status = fineTuneCaffe if status
      status = saveBuiltModel if status

      if status
        @samosaState.setState(Messaging::States::Samosa::ChiaStates.built, "100%")
      else
        @samosaState.setState(Messaging::States::Samosa::ChiaStates.failed)
      end
    end

    def downloadFiles
      Messaging.logger.debug("Downloading files")
      @samosaState.setState(Messaging::States::Samosa::ChiaStates.downloading)
      # download build files
      status = @fileManager.getChiaBuildFiles
      # untar files
      status = @fileManager.untarBuildInput if status
      # get clips
      status = @fileManager.downloadClips if status
    end

    def extractFrames
      Messaging.logger.debug("Extract frames")
      @samosaState.setState(Messaging::States::Samosa::ChiaStates.extracting)
      @fileManager.extractFrames
    end

    def fineTuneCaffe
      Messaging.logger.debug("Finetune Caffe")
      @samosaState.setState(Messaging::States::Samosa::ChiaStates.building)
      @fileManager.fineTuneCaffe
    end

    def saveBuiltModel
      Messaging.logger.debug("Save Caffe model")
      @fileManager.saveBuiltModel
    end

  end
end
