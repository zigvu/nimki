module Handlers
  class StateQuery
    def initialize(header, message, captureState)
      @header = header
      @message = message
      @captureState = captureState
    end

    def handle
      returnHeader = Messaging::Messages::Header.statusSuccess
      @message.state = @captureState.getState()
      returnMessage = @message
      return returnHeader, returnMessage
    end

    def canHandle?
      Messaging::Messages::VideoCapture::StateQuery.new(nil).isSameType?(@message)
    end
  end
end
