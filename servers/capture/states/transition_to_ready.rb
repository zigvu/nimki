module States
  class TransitionToReady
    def initialize(captureState)
      @captureState = captureState
    end

    def transition
      success = false
      case @captureState.getState
      when Messaging::VideoCapture::CaptureStates.unknown
        success = transitionFromUnknown
      when Messaging::VideoCapture::CaptureStates.ready
        # already in ready state
        success = true
      when Messaging::VideoCapture::CaptureStates.capturing
        # cannot go directly from capturing to ready - need to stop first
        success = false
      when Messaging::VideoCapture::CaptureStates.stopped
        success = transitionFromStopped
      end

      return success
    end

    private
      def transitionFromUnknown
        @captureState.setState(Messaging::VideoCapture::CaptureStates.stopped)
        transitionFromStopped
      end

      def transitionFromStopped
        return false if !@captureState.captureDetails.hasDetails?

        # start base
        @captureState.shellManager.baseStart
        # load chrome
        @captureState.shellManager.chromeStart(@captureState.captureDetails.url)

        @captureState.setState(Messaging::VideoCapture::CaptureStates.ready)

        true
      end

  end
end
