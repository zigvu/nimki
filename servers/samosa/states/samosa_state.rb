require "thread"

module States
  class SamosaState
    attr_accessor :operationType, :fakeGpu
    attr_accessor :_samosaClient, :_storageClient
    attr_accessor :_chiaBuildManager, :_chiaBuildManagerThread
    attr_accessor :_khajuriEvalManager, :_khajuriEvalManagerThreads

    def initialize
      # track state of variable - use mutex to make it thread safe
      @currentStateMutex = Mutex.new
      # both chia and khajuri have unknown state
      setState(Messaging::States::Samosa::ChiaStates.unknown)
    end

    # thread safe state
    def getState
      return @currentState, @currentProgress
    end
    def setState(newState, progress="0%")
      Messaging.logger.debug("Changing state to: #{newState} - #{progress}")
      @currentStateMutex.synchronize {
        @currentState = newState
        @currentProgress = progress
      }
    end

    def khajuriDetails
      @_khajuriDetails ||= States::KhajuriDetails.new
    end
    def chiaDetails
      @_chiaDetails ||= States::ChiaDetails.new
    end

    def storageClient
      if operationType.isChia?
        storageHostname = chiaDetails.storageHostname
      else
        storageHostname = khajuriDetails.storageHostname
      end
      # storageClient is initialized once capture details have been set
      @_storageClient ||= Messaging::Connections::Clients::StorageClient.new(
        storageHostname
      )
    end
    def samosaClient
      # samosaClient is initialized during initial ping
      @_samosaClient ||= Connections::SamosaClient.new
    end

    def chiaBuildManager
      if not @_chiaBuildManager
        @_chiaBuildManager = Chia::BuildManager.new(self)
        @_chiaBuildManagerThread = Thread.new {
          thSamosaClient = Connections::SamosaClient.new
          thStorageClient = Messaging::Connections::Clients::StorageClient.new(
            chiaDetails.storageHostname
          )
          @_chiaBuildManager.run(thSamosaClient, thStorageClient)
        }
      end
      @_chiaBuildManager
    end
    def khajuriEvalManager
      if not @_khajuriEvalManager
        @_khajuriEvalManager = Khajuri::EvalManager.new(self)
        @_khajuriEvalManagerThreads = []

        @_khajuriEvalManagerThreads << Thread.new {
          thSamosaClient = Connections::SamosaClient.new
          thStorageClient = Messaging::Connections::Clients::StorageClient.new(
            khajuriDetails.storageHostname
          )
          @_khajuriEvalManager.runKhajuriProcess(thSamosaClient, thStorageClient)
        }
        @_khajuriEvalManagerThreads << Thread.new {
          thSamosaClient = Connections::SamosaClient.new
          thStorageClient = Messaging::Connections::Clients::StorageClient.new(
            khajuriDetails.storageHostname
          )
          @_khajuriEvalManager.runDownloadData(thSamosaClient, thStorageClient)
        }
        @_khajuriEvalManagerThreads << Thread.new {
          thSamosaClient = Connections::SamosaClient.new
          thStorageClient = Messaging::Connections::Clients::StorageClient.new(
            khajuriDetails.storageHostname
          )
          @_khajuriEvalManager.runUploadResults(thSamosaClient, thStorageClient)
        }
      end
      @_khajuriEvalManager
    end

    # reset in orderly fashion
    def reset
      @_chiaBuildManagerThread.join if @_chiaBuildManager
      @_chiaBuildManager = nil

      if @_khajuriEvalManager
        @_khajuriEvalManager.reset
        @_khajuriEvalManagerThreads.map {|thrd| thrd.join }
        @_khajuriEvalManager = nil
      end

      @_storageClient = nil
      @_samosaClient = nil

      # both chia and khajuri have stopped state
      setState(Messaging::States::Samosa::ChiaStates.stopped)
    end

  end
end
