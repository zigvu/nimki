require "thread"

module States
  class CaptureState
    attr_accessor :shellManager, :threadManager, :captureDetails

    def initialize(shellManager, threadManager, captureDetails)
      @shellManager = shellManager
      @threadManager = threadManager
      @captureDetails = captureDetails

      # track state of variable - use mutex to make it thread safe
      @currentStateMutex = Mutex.new
      setState(Messaging::States::VideoCapture::CaptureStates.unknown)
    end

    # Get state
    def getState
      @currentState
    end

    def setState(newState)
      Messaging.logger.debug("Changing state to: #{newState}")
      @currentStateMutex.synchronize { @currentState = newState }
    end
  end
end
