module Handlers
  class Transition
    def initialize(header, message, captureState)
      @header = header
      @message = message
      @captureState = captureState
    end

    def handle
      success = false

      # transition state
      requestedState = Messaging::States::VideoCapture::CaptureStates.new(@message.state)
      case requestedState
      when Messaging::States::VideoCapture::CaptureStates.unknown
        # cannot transition to unknown state explicitely
        success = false
      when Messaging::States::VideoCapture::CaptureStates.ready
        success = States::TransitionToReady.new(@captureState).transition
      when Messaging::States::VideoCapture::CaptureStates.capturing
        success = States::TransitionToCapturing.new(@captureState).transition
      when Messaging::States::VideoCapture::CaptureStates.stopped
        success = States::TransitionToStopped.new(@captureState).transition
      end

      if success
        returnHeader = Messaging::Messages::Header.dataSuccess
      else
        returnHeader = Messaging::Messages::Header.dataFailure
      end

      @message.state = @captureState.getState()
      returnMessage = @message
      return returnHeader, returnMessage
    end

    def canHandle?
      Messaging::Messages::VideoCapture::StateTransition.new(nil).isSameType?(@message)
    end
  end
end
