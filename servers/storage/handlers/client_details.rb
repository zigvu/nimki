module Handlers
  class ClientDetails
    def initialize(header, message, storageState)
      @header = header
      @message = message
      @storageState = storageState
    end

    def handle
      @storageState.clientDetails.fromMessage(@message)
      returnHeader = Messaging::Messages::Header.dataSuccess
      returnMessage = @message
      return returnHeader, returnMessage
    end

    def canHandle?
      Messaging::Messages::Storage::ClientDetails.new(nil).isSameType?(@message)
    end
  end
end
