module Handlers
  class ClientDetails
    def initialize(header, message, storageState)
      @header = header
      @message = message
      @storageState = storageState
    end

    def handle
      returnHeader = Messaging::Messages::Header.dataSuccess
      returnMessage = @message

      @storageState.clientDetails.fromMessage(@message)

      return returnHeader, returnMessage
    end

    def canHandle?
      Messaging::Messages::Storage::ClientDetails.new(nil).isSameType?(@message)
    end
  end
end
