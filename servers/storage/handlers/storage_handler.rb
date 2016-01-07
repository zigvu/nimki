module Handlers
  class StorageHandler
    def initialize(storageState)
      @storageState = storageState
    end

    def call(header, message)
      Messaging.logger.debug("StorageHandler: Request header : #{header}")
      Messaging.logger.debug("StorageHandler: Request message: #{message}")

      returnHeader = Messaging::Messages::Header.statusFailure
      returnMessage = Messaging::Messages::MessageFactory.getNoneMessage

      begin
        pingHandler = Handlers::Ping.new(header, message, @storageState)
        returnHeader, returnMessage = pingHandler.handle if pingHandler.canHandle?

        clientDetails = Handlers::ClientDetails.new(header, message, @storageState)
        returnHeader, returnMessage = clientDetails.handle if clientDetails.canHandle?

        fileOperations = Handlers::FileOperations.new(header, message, @storageState)
        returnHeader, returnMessage = fileOperations.handle if fileOperations.canHandle?

      rescue => e
        Messaging.logger.error("StorageHandler: #{e}")
      end

      Messaging.logger.debug("StorageHandler: Served header : #{returnHeader}")
      Messaging.logger.debug("StorageHandler: Served message: #{returnMessage}")

      return returnHeader, returnMessage
    end
  end
end
