module Handlers
  class Ping
    def initialize(header, message, samosaState)
      @header = header
      @message = message
      @samosaState = samosaState
    end

    def handle
      returnHeader = Messaging::Messages::Header.pingSuccess
      returnMessage = Messaging::Messages::MessageFactory.getNoneMessage

      return returnHeader, returnMessage
    end

    def canHandle?
      @header.type.isPing?
    end
  end
end
