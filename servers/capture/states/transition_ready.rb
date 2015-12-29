module States
  class TransitionReady
    def initialize(captureState)
      @captureState = captureState
    end

    def transition
      success = false
      case @captureState.getState
      when Messaging::VideoCapture::CaptureStates.unknown
        #
        success = true
      when Messaging::VideoCapture::CaptureStates.ready
        success = true
      end

      return success
    end

    private
      def transitionFromStopped
        # warn if non zero length
        if !(@captureState.qLocalFiles.empty? &&
          @captureState.qLocalFiles.empty? &&
          @captureState.qLocalFiles.empty?)
          Messaging.logger.warn("The queues are not empty")
        end
        # empty queues
        @captureState.qLocalFiles.clear()
        @captureState.qRasbariRequested.clear()
        @captureState.qStorageRequested.clear()

        # pkill processes
        

        true
      end

  end
end
