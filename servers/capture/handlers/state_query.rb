module Handlers
  class StateQuery
    def initialize(header, message, captureState)
      @header = header
      @message = message
      @captureState = captureState
    end

    def handle
      returnHeader = Messaging::Messages::Header.statusSuccess
      returnMessage = @message
      returnMessage.trace = "State query successful"

      returnMessage.state = @captureState.getState()

      return returnHeader, returnMessage
    end

    def canHandle?
      Messaging::Messages::VideoCapture::StateQuery.new(nil).isSameType?(@message)
    end
  end
end
