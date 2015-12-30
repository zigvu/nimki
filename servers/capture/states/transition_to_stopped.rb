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

        # TODO: delete the last clip ffmpeg was creating

        # TODO: until the queues are empty, do not return
        if !(@captureState.qLocalFiles.empty? &&
          @captureState.qLocalFiles.empty? &&
          @captureState.qLocalFiles.empty?)
          Messaging.logger.warn("The queues are not empty")
        end

        @captureState.setState(Messaging::VideoCapture::CaptureStates.stopped)
        @captureState.captureDetails.reset

        true
      end

  end
end
