module Handlers
  class StateQueryHandler
    def initialize(header, message, bufferManager)
      @header = header
      @message = message
      @bufferManager = bufferManager
    end

    def handle
      returnHeader = Messaging::Messages::Header.statusSuccess
      @message.state = @bufferManager.getState
      returnMessage = @message
      return returnHeader, returnMessage
    end

    def canHandle?
      Messaging::Messages::VideoCapture::StateQuery.new(nil).isSameType?(@message)
    end
  end
end
