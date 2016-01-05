require 'socket'

module Connections
  class NimkiClient < Messaging::Connections::GenericClient

    def initialize
      hostname = Socket.gethostname

      exchangeName = "#{Messaging.config.video_capture.exchange}"
      responseRoutingKey = "#{Messaging.config.video_capture.routing_keys.nimki.client}.#{hostname}"
      machineRoutingKey = "#{Messaging.config.video_capture.routing_keys.rasbari.server}"

      super(exchangeName, responseRoutingKey, machineRoutingKey)
      Messaging.logger.info("Start NimkiClient for hostname: #{hostname}")
    end

    def getClipDetails(captureId, ffmpegName)
      header = Messaging::Messages::Header.dataRequest
      message = Messaging::Messages::VideoCapture::ClipDetails.new(nil)
      message.captureId = captureId
      message.ffmpegName = ffmpegName
      _, response = call(header, message)
      response
    end

  end
end
