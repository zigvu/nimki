module Handlers
  class Transition
    def initialize(header, message, captureState)
      @header = header
      @message = message
      @captureState = captureState
    end

    def handle
      returnMessage = @message
      success = false

      # transition state
      requestedState = Messaging::States::VideoCapture::CaptureStates.new(@message.state)
      case requestedState
      when Messaging::States::VideoCapture::CaptureStates.unknown
        # cannot transition to unknown state explicitely
        success = false
      when Messaging::States::VideoCapture::CaptureStates.ready
        success = Handlers::Transitions::ToReady.new(@captureState).transition
      when Messaging::States::VideoCapture::CaptureStates.capturing
        success = Handlers::Transitions::ToCapturing.new(@captureState).transition
      when Messaging::States::VideoCapture::CaptureStates.stopped
        success = Handlers::Transitions::ToStopped.new(@captureState).transition
      end

      if success
        returnHeader = Messaging::Messages::Header.statusSuccess
        returnMessage.trace = "State transition successful"
      else
        returnHeader = Messaging::Messages::Header.statusFailure
        returnMessage.trace = "State transition failed"
      end

      returnMessage.state = @captureState.getState()

      return returnHeader, returnMessage
    end

    def canHandle?
      Messaging::Messages::VideoCapture::StateTransition.new(nil).isSameType?(@message)
    end
  end
end
