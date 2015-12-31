module States
  class TransitionToStopped
    def initialize(captureState)
      @captureState = captureState
    end

    def transition
      success = false
      case @captureState.getState
      when Messaging::VideoCapture::CaptureStates.unknown
        # cannot go directly from unknown to stopped
        success = false
      when Messaging::VideoCapture::CaptureStates.ready
        success = transitionFromReady
      when Messaging::VideoCapture::CaptureStates.capturing
        success = transitionFromCapturing
      when Messaging::VideoCapture::CaptureStates.stopped
        # already in stopped state
        success = true
      end

      return success
    end

    private
      def transitionFromReady
        @captureState.shellManager.stop
        @captureState.setState(Messaging::VideoCapture::CaptureStates.stopped)

        true
      end

      def transitionFromCapturing
        # stop creating new clips
        @captureState.shellManager.stop

        @captureState.threadManager.reset
        @captureState.captureDetails.reset
        @captureState.setState(Messaging::VideoCapture::CaptureStates.stopped)

        true
      end

  end
end
