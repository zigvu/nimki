require "thread"

module States
  class CaptureState
    attr_accessor :_shellManager, :_threadManager, :_captureDetails
    attr_accessor :_captureClient, :_storageClient

    def initialize
      # track state of variable - use mutex to make it thread safe
      @currentStateMutex = Mutex.new
      setState(Messaging::States::VideoCapture::CaptureStates.unknown)
    end

    # thread safe state
    def getState
      @currentState
    end
    def setState(newState)
      Messaging.logger.debug("Changing state to: #{newState}")
      @currentStateMutex.synchronize { @currentState = newState }
    end

    def shellManager
      @_shellManager ||= ShellCommands::Manager.new
    end
    def threadManager
      @_threadManager ||= States::ThreadManager.new
    end
    def captureDetails
      @_captureDetails ||= States::CaptureDetails.new
    end

    def captureClient
      # captureClient is initialized during initial ping
      @_captureClient ||= Connections::CaptureClient.new
    end
    def storageClient
      # storageClient is initialized once capture details have been set
      @_storageClient ||= true #Connections::CaptureClient.new
    end

    # reset in orderly fashion
    def reset
      @_shellManager.stop if @_shellManager
      @_threadManager.reset if @_threadManager
      @_captureDetails.reset if @_captureDetails

      @_captureClient = nil
      @_storageClient = nil

      setState(Messaging::States::VideoCapture::CaptureStates.stopped)
    end

  end
end
