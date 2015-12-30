module Handlers
  class VncServerStart
    def initialize(header, message, captureState)
      @header = header
      @message = message
      @captureState = captureState
    end

    def handle
      returnHeader = Messaging::Messages::Header.statusSuccess
      # start vnc server
      @captureState.shellManager.vncStart
      returnMessage = @message
      return returnHeader, returnMessage
    end

    def canHandle?
      Messaging::Messages::VideoCapture::VncServerStart.new(nil).isSameType?(@message)
    end
  end
end
