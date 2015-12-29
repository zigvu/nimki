module Handlers
  class TransitionHandler
    def initialize(header, message, captureState)
      @header = header
      @message = message
      @captureState = captureState
    end

    def handle
      success = false

      # transition state
      requestedState = Messaging::VideoCapture::CaptureStates.new(@message.state)
      case requestedState
      when Messaging::VideoCapture::CaptureStates.ready
        success = States::TransitionReady.new(@captureState).transition
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
