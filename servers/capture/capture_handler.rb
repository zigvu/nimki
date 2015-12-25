class CaptureHandler
  def initialize(bufferManager)
    @bufferManager = bufferManager
  end

  def call(header, message)
    Messaging.logger.debug("CaptureHandler: Request header: #{header}")

    pingHandler = Handlers::PingHandler.new(header, message, @bufferManager)
    return pingHandler.handle if pingHandler.canHandle?

    stateQueryHandler = Handlers::StateQueryHandler.new(header, message, @bufferManager)
    return stateQueryHandler.handle if stateQueryHandler.canHandle?


    Messaging.logger.debug("CaptureHandler: Served header : #{returnHeader}")
    Messaging.logger.debug("CaptureHandler: Served message: #{returnMessage}")

    return returnHeader, returnMessage
  end
end
