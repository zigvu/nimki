module Handlers
  class CaptureHandler
    def initialize(captureState)
      @captureState = captureState
    end

    def call(header, message)
      Messaging.logger.debug("CaptureHandler: Request header : #{header}")
      Messaging.logger.debug("CaptureHandler: Request message: #{message}")

      pingHandler = Handlers::PingHandler.new(header, message, @captureState)
      return pingHandler.handle if pingHandler.canHandle?

      stateQueryHandler = Handlers::StateQueryHandler.new(header, message, @captureState)
      return stateQueryHandler.handle if stateQueryHandler.canHandle?

      transitionHandler = Handlers::TransitionHandler.new(header, message, @captureState)
      return transitionHandler.handle if transitionHandler.canHandle?


      Messaging.logger.debug("CaptureHandler: Served header : #{returnHeader}")
      Messaging.logger.debug("CaptureHandler: Served message: #{returnMessage}")

      return returnHeader, returnMessage
    end
  end
end
