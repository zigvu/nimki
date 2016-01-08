module Handlers
  class CaptureDetails
    def initialize(header, message, captureState)
      @header = header
      @message = message
      @captureState = captureState
    end

    def handle
      returnHeader = Messaging::Messages::Header.dataSuccess

      @captureState.captureDetails.fromMessage(@message)
      # ensure that can reach storage server
      if @captureState.storageClient.isRemoteAlive?
        # set thread manager variables
        tm = @captureState.threadManager
        tm.setClients(@captureState.captureClient, @captureState.storageClient)
        tm.setCaptureDetails(@captureState.captureDetails)
      else
        returnHeader = Messaging::Messages::Header.dataFailure
      end

      returnMessage = @message
      return returnHeader, returnMessage
    end

    def canHandle?
      Messaging::Messages::VideoCapture::CaptureDetails.new(nil).isSameType?(@message)
    end
  end
end
