module Handlers
  class CaptureDetails
    def initialize(header, message, captureState)
      @header = header
      @message = message
      @captureState = captureState
    end

    def handle
      @captureState.captureDetails.fromMessage(@message)
      # TODO: connect with storage server and ping

      # set thread manager variables
      tm = @captureState.threadManager
      tm.setClients(@captureState.captureClient, @captureState.storageClient)
      tm.setCaptureDetails(@captureState.captureDetails)

      returnHeader = Messaging::Messages::Header.dataSuccess
      returnMessage = @message
      return returnHeader, returnMessage
    end

    def canHandle?
      Messaging::Messages::VideoCapture::CaptureDetails.new(nil).isSameType?(@message)
    end
  end
end
