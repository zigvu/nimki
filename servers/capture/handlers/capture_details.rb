module Handlers
  class CaptureDetails
    def initialize(header, message, captureState)
      @header = header
      @message = message
      @captureState = captureState
    end

    def handle
      returnHeader = Messaging::Messages::Header.dataFailure
      returnMessage = @message

      @captureState.captureDetails.fromMessage(@message)

      # ensure that rasbari server is alive
      status, trace = @captureState.captureClient.isRemoteAlive?
      if status
        # ensure that client can reach storage server
        status, trace = @captureState.storageClient.isRemoteAlive?
        if status
          # set thread manager variables
          tm = @captureState.threadManager
          tm.setClients(@captureState.captureClient, @captureState.storageClient)
          tm.setCaptureDetails(@captureState.captureDetails)

          returnHeader = Messaging::Messages::Header.dataSuccess
          trace = "Capture details set successfully"
        else
          trace = "Cannot ping storage server"
        end
      else
        trace = "Cannot ping rasbari server"
      end

      returnMessage.trace = trace
      return returnHeader, returnMessage
    end

    def canHandle?
      Messaging::Messages::VideoCapture::CaptureDetails.new(nil).isSameType?(@message)
    end
  end
end
