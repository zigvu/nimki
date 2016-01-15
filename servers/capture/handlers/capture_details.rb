module Handlers
  class CaptureDetails
    def initialize(header, message, captureState)
      @header = header
      @message = message
      @captureState = captureState
    end

    def handle
      returnHeader = Messaging::Messages::Header.dataSuccess
      returnMessage = @message
      returnMessage.trace = "Capture details set successfully"

      @captureState.captureDetails.fromMessage(@message)
      # ensure that client can reach storage server
      if @captureState.storageClient.isRemoteAlive?
        # set thread manager variables
        tm = @captureState.threadManager
        tm.setClients(@captureState.captureClient, @captureState.storageClient)
        tm.setCaptureDetails(@captureState.captureDetails)
      else
        returnHeader = Messaging::Messages::Header.dataFailure
        returnMessage.trace = "Cannot ping storage server"
      end

      return returnHeader, returnMessage
    end

    def canHandle?
      Messaging::Messages::VideoCapture::CaptureDetails.new(nil).isSameType?(@message)
    end
  end
end
