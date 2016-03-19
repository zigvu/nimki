require "thread"

module States
  class SamosaState
    attr_accessor :operationType
    attr_accessor :_samosaClient, :_storageClient
    attr_accessor :_chiaBuildManager, :_chiaBuildManagerThread

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
        @_chiaBuildManagerThread = Thread.new { @_chiaBuildManager.run }
      end
      @_chiaBuildManager
    end

    # reset in orderly fashion
    def reset
      @_chiaBuildManagerThread.join if @_chiaBuildManager
      @_chiaBuildManager = nil

      @_storageClient = nil
      @_samosaClient = nil

      setState(Messaging::States::Samosa::ChiaStates.stopped)
    end

  end
end
