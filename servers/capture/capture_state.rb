require "thread"

class CaptureState
  attr_accessor :qLocalFiles, :qRasbariRequested, :qStorageRequested
  attr_reader :currentState

  def initialize
    # queues to manage flow of clips in a thread safe manner
    @qLocalFiles = Queue.new
    @qRasbariRequested = Queue.new
    @qStorageRequested = Queue.new

    # track state of variable - use mutex to make it thread safe
    @currentStateMutex = Mutex.new
    setState(Messaging::VideoCapture::CaptureStates.unknown)
  end

  def setState(newState)
    Messaging.logger.debug("Changing state to: #{newState}")
    @currentStateMutex.synchronize { @currentState = newState }
  end
end
