module States
  class TransitionToReady
    def initialize(captureState)
      @captureState = captureState
    end

    def transition
      success = false
      case @captureState.getState
      when Messaging::States::VideoCapture::CaptureStates.unknown
        success = transitionFromUnknown
      when Messaging::States::VideoCapture::CaptureStates.ready
        # already in ready state
        success = true
      when Messaging::States::VideoCapture::CaptureStates.capturing
        # cannot go directly from capturing to ready - need to stop first
        success = false
      when Messaging::States::VideoCapture::CaptureStates.stopped
        success = transitionFromStopped
      end

      return success
    end

    private
      def transitionFromUnknown
        @captureState.setState(Messaging::States::VideoCapture::CaptureStates.stopped)
        transitionFromStopped
      end

      def transitionFromStopped
        return false if !@captureState.captureDetails.hasDetails?

        # start base
        @captureState.shellManager.baseStart
        # load chrome
        @captureState.shellManager.chromeStart(@captureState.captureDetails.url)

        @captureState.setState(Messaging::States::VideoCapture::CaptureStates.ready)

        true
      end

  end
end
