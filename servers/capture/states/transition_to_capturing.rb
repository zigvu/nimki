module States
  class TransitionToCapturing
    def initialize(captureState)
      @captureState = captureState
    end

    def transition
      success = false
      case @captureState.getState
      when Messaging::VideoCapture::CaptureStates.unknown
        # cannot go directly from unknown to capturing
        success = false
      when Messaging::VideoCapture::CaptureStates.ready
        success = transitionFromReady
      when Messaging::VideoCapture::CaptureStates.capturing
        # already in capturing state
        success = true
      when Messaging::VideoCapture::CaptureStates.stopped
        # cannot go directly from stopped to capturing - need to ready first
        success = false
      end

      return success
    end

    private
      def transitionFromReady
        # start ffmpeg
        @captureState.shellManager.ffmpegStart(@captureState.captureDetails.localFileFolder)

        @captureState.setState(Messaging::VideoCapture::CaptureStates.capturing)

        true
      end

  end
end
