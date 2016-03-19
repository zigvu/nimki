module Handlers
  class SamosaHandler
    def initialize(samosaState)
      @samosaState = samosaState
    end

    def call(header, message)
      Messaging.logger.debug("Request header : #{header}")
      Messaging.logger.debug("Request message: #{message}")

      returnHeader = Messaging::Messages::Header.statusFailure
      returnMessage = Messaging::Messages::MessageFactory.getNoneMessage
      returnMessage.trace = "Message handler not found"


      begin
        pingHandler = Handlers::Ping.new(header, message, @samosaState)
        returnHeader, returnMessage = pingHandler.handle if pingHandler.canHandle?

        stateQuery = Handlers::StateQuery.new(header, message, @samosaState)
        returnHeader, returnMessage = stateQuery.handle if stateQuery.canHandle?

        # TODO: write Khajuri handlers

        # Chia handlers
        chiaDetails = Handlers::ChiaDetails.new(header, message, @samosaState)
        returnHeader, returnMessage = chiaDetails.handle if chiaDetails.canHandle?

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
