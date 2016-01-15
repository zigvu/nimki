module Handlers
  class CaptureHandler
    def initialize(captureState)
      @captureState = captureState
    end

    def call(header, message)
      Messaging.logger.debug("Request header : #{header}")
      Messaging.logger.debug("Request message: #{message}")

      returnHeader = Messaging::Messages::Header.statusFailure
      returnMessage = Messaging::Messages::MessageFactory.getNoneMessage
      returnMessage.trace = "Message handler not found"

      begin
        pingHandler = Handlers::Ping.new(header, message, @captureState)
        returnHeader, returnMessage = pingHandler.handle if pingHandler.canHandle?

        stateQueryHandler = Handlers::StateQuery.new(header, message, @captureState)
        returnHeader, returnMessage = stateQueryHandler.handle if stateQueryHandler.canHandle?

        transitionHandler = Handlers::Transition.new(header, message, @captureState)
        returnHeader, returnMessage = transitionHandler.handle if transitionHandler.canHandle?

        captureDetailsHandler = Handlers::CaptureDetails.new(header, message, @captureState)
        returnHeader, returnMessage = captureDetailsHandler.handle if captureDetailsHandler.canHandle?

        vncServerStartHandler = Handlers::VncServerStart.new(header, message, @captureState)
        returnHeader, returnMessage = vncServerStartHandler.handle if vncServerStartHandler.canHandle?

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
