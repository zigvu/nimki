require "thread"

module Khajuri
  class EvalManager
    attr_accessor :curEvalClipIds, :resultsQueue

    def initialize(samosaState)
      @samosaState = samosaState
      @curEvalClipIdsMutex = Mutex.new
      @curEvalClipIds = []
      @maxNumClipsToDownload = 10
      @resultsQueue = Queue.new
      @needsReset = false
      @khajuriProcessStartedMutex = Mutex.new
      @khajuriProcessStarted = false
    end

    def getCurEvalClipIdCount
      clipIdCount = nil
      @curEvalClipIdsMutex.synchronize { clipIdCount = @curEvalClipIds.count }
      clipIdCount
    end
    def addClipIdToCurEval(clipId)
      @curEvalClipIdsMutex.synchronize { @curEvalClipIds << clipId.to_i }
    end
    def removeClipIdFromCurEval(clipId)
      @curEvalClipIdsMutex.synchronize { @curEvalClipIds.delete(clipId.to_i) }
    end

    def isKhajuriProcessStarted?
      procStarted = false
      @khajuriProcessStartedMutex.synchronize { procStarted = @khajuriProcessStarted }
      procStarted
    end
    def setKhajuriProcessStarted
      @khajuriProcessStartedMutex.synchronize { @khajuriProcessStarted = true }
    end


    def runDownloadData(thSamosaClient, thStorageClient)
      # ensure khajuri process has started
      while !isKhajuriProcessStarted?
        sleep 2
        return if @needsReset
      end

      Messaging.logger.debug("EvalManager: Start thread - runDownloadData")
      fileManager = Khajuri::FileManager.new(
        @samosaState.khajuriDetails, thSamosaClient, thStorageClient, @samosaState.fakeGpu
      )
      kpc = Connections::KhajuriPipelineClient.new()
      fileManager.getClipIds.each do |clipId|
        break if @needsReset
        status, clipEvalMessage = fileManager.downloadClip(clipId)
        next if !status
        status, _ = kpc.sendClipEvalDetails(clipEvalMessage)
        next if !status

        Messaging.logger.debug("EvalManager: Added clip #{clipId}")
        addClipIdToCurEval(clipId)
        while getCurEvalClipIdCount >= @maxNumClipsToDownload
          sleep 10
        end
      end
      # put poison pill
      kpc.sendClipEvalDetails(Messaging::Messages::Samosa::ClipEvalDetails.new(nil))
      Messaging.logger.debug("EvalManager: End thread - runDownloadData")
    end

    def runUploadResults(thSamosaClient, thStorageClient)
      # ensure khajuri process has started
      while !isKhajuriProcessStarted?
        sleep 2
        return if @needsReset
      end

      Messaging.logger.debug("EvalManager: Start thread - runUploadResults")
      fileManager = Khajuri::FileManager.new(
        @samosaState.khajuriDetails, thSamosaClient, thStorageClient, @samosaState.fakeGpu
      )
      handler = Handlers::PipelineResultsHandler.new(@resultsQueue)
      Connections::KhajuriPipelineServer.new(handler)
      @samosaState.setState(Messaging::States::Samosa::KhajuriStates.evaluating)
      state, progress = @samosaState.getState
      fileManager.updateState(state, progress)

      while true
        return if @needsReset
        # block if no result has been produced
        clipEvalMessage = @resultsQueue.pop
        Messaging.logger.debug("EvalManager: Saving result of clip: #{clipEvalMessage.clipId}")
        # break if poison pill
        break if clipEvalMessage.clipId == nil || clipEvalMessage.clipId == ""

        fileManager.uploadResult(clipEvalMessage)
        removeClipIdFromCurEval(clipEvalMessage.clipId)
      end
      @samosaState.setState(Messaging::States::Samosa::KhajuriStates.evaluated)
      state, progress = @samosaState.getState
      fileManager.updateState(state, progress)
      Messaging.logger.debug("EvalManager: End thread - runUploadResults")
    end

    def runKhajuriProcess(thSamosaClient, thStorageClient)
      Messaging.logger.debug("EvalManager: Start thread - runKhajuriProcess")
      fileManager = Khajuri::FileManager.new(
        @samosaState.khajuriDetails, thSamosaClient, thStorageClient, @samosaState.fakeGpu
      )
      status = fileManager.getKhajuriInputFiles
      status = fileManager.untarBuildInput if status

      setKhajuriProcessStarted
      fileManager.runKhajuriProcess
      Messaging.logger.debug("EvalManager: End thread - runKhajuriProcess")
    end

    def reset
      @needsReset = true
      @resultsQueue.clear
      @resultsQueue << Messaging::States::Samosa::ClipEvalStates.new(nil)
      sleep(1)
      @resultsQueue.clear
    end

  end
end
