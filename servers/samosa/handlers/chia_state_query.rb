module Handlers
  class ChiaStateQuery
    def initialize(header, message, samosaState)
      @header = header
      @message = message
      @samosaState = samosaState
    end

    def handle
      returnHeader = Messaging::Messages::Header.statusSuccess
      returnMessage = @message
      returnMessage.trace = "State query successful"

      returnMessage.state, returnMessage.progress = @samosaState.getState()

      return returnHeader, returnMessage
    end

    def canHandle?
      Messaging::Messages::Samosa::ChiaStateQuery.new(nil).isSameType?(@message)
    end
  end
end
