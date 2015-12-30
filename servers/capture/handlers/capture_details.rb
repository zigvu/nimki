module Handlers
  class CaptureDetails
    def initialize(header, message, captureState)
      @header = header
      @message = message
      @captureState = captureState
    end

    def handle
      @captureState.captureDetails.fromMessage(@message)
      returnHeader = Messaging::Messages::Header.dataSuccess
      returnMessage = @message
      return returnHeader, returnMessage
    end

    def canHandle?
      Messaging::Messages::VideoCapture::CaptureDetails.new(nil).isSameType?(@message)
    end
  end
end
