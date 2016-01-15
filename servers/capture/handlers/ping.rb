module Handlers
  class Ping
    def initialize(header, message, captureState)
      @header = header
      @message = message
      @captureState = captureState
    end

    def handle
      returnHeader = Messaging::Messages::Header.pingSuccess
      returnMessage = @message

      # ensure that rasbari server is alive
      status, trace = @captureState.captureClient.isRemoteAlive?
      returnMessage.trace = trace

      if !status
        returnHeader = Messaging::Messages::Header.pingFailure
        returnMessage.trace = "Cannot ping rasbari server"
      end

      return returnHeader, returnMessage
    end

    def canHandle?
      @header.type.isPing?
    end
  end
end
