module Handlers
  class StorageHandler
    def initialize(storageState)
      @storageState = storageState
    end

    def call(header, message)
      Messaging.logger.debug("Request header : #{header}")
      Messaging.logger.debug("Request message: #{message}")

      returnHeader = Messaging::Messages::Header.statusFailure
      returnMessage = Messaging::Messages::MessageFactory.getNoneMessage
      returnMessage.trace = "Message handler not found"


      begin
        pingHandler = Handlers::Ping.new(header, message, @storageState)
        returnHeader, returnMessage = pingHandler.handle if pingHandler.canHandle?

        clientDetails = Handlers::ClientDetails.new(header, message, @storageState)
        returnHeader, returnMessage = clientDetails.handle if clientDetails.canHandle?

        fileOperations = Handlers::FileOperations.new(header, message, @storageState)
        returnHeader, returnMessage = fileOperations.handle if fileOperations.canHandle?

      rescue Exception => e
        returnHeader = Messaging::Messages::Header.statusFailure
        returnMessage.trace = "Error: #{e.backtrace.first}"

        Messaging.logger.error(e)
      end

      Messaging.logger.debug("Served header : #{returnHeader}")
      Messaging.logger.debug("Served message: #{returnMessage}")

      return returnHeader, returnMessage
    end
  end
end
