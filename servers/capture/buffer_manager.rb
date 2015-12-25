class BufferManager
  def initialize(captureState)
    Messaging.logger.debug("Starting buffer manager")
    @captureState = captureState
  end

  def getState
    @captureState.currentState
  end

  def isStateReady?
  end
  def setStateReady
    # pkill existing processes
    # empty queues
    # start capture processes
    # start saving files but not saving to rasbari
    @captureState.setState(Messaging::VideoCapture::CaptureStates.ready)
  end

  def isStateCapturing?
  end
  def setStateCapturing
  end

  def isStateStopped?
  end
  def setStateStopped
  end


end
