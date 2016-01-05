module Handlers
  module Transitions
    class ToStopped
      def initialize(captureState)
        @captureState = captureState
      end

      def transition
        success = false
        case @captureState.getState
        when Messaging::States::VideoCapture::CaptureStates.unknown
          success = transitionFromUnknown
        when Messaging::States::VideoCapture::CaptureStates.ready
          success = transitionFromReady
        when Messaging::States::VideoCapture::CaptureStates.capturing
          success = transitionFromCapturing
        when Messaging::States::VideoCapture::CaptureStates.stopped
          # already in stopped state
          success = true
        end

        return success
      end

      private

        def transitionFromUnknown
          # we stop all processes and kill connections
          @captureState.reset

          true
        end

        def transitionFromReady
          # we stop all processes but keep connections alive
          @captureState.shellManager.stop
          @captureState.setState(Messaging::States::VideoCapture::CaptureStates.stopped)

          true
        end

        def transitionFromCapturing
          # we stop all processes and kill connections
          @captureState.reset

          true
        end

    end
  end
end
