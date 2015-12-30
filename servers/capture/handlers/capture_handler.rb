module Handlers
  class CaptureHandler
    def initialize(captureState)
      @captureState = captureState
    end

    def call(header, message)
      Messaging.logger.debug("CaptureHandler: Request header : #{header}")
      Messaging.logger.debug("CaptureHandler: Request message: #{message}")

      returnHeader = Messaging::Messages::Header.statusFailure
      returnMessage = Messaging::Messages::MessageFactory.getNoneMessage

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
      rescue => e
        Messaging.logger.error("CaptureHandler: #{e}")
      end

      Messaging.logger.debug("CaptureHandler: Served header : #{returnHeader}")
      Messaging.logger.debug("CaptureHandler: Served message: #{returnMessage}")

      return returnHeader, returnMessage
    end
  end
end
