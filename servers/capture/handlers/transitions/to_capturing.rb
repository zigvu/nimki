module Handlers
  module Transitions
    class ToCapturing
      def initialize(captureState)
        @captureState = captureState
      end

      def transition
        success = false
        case @captureState.getState
        when Messaging::States::VideoCapture::CaptureStates.unknown
          # cannot go directly from unknown to capturing
          success = false
        when Messaging::States::VideoCapture::CaptureStates.ready
          success = transitionFromReady
        when Messaging::States::VideoCapture::CaptureStates.capturing
          # already in capturing state
          success = true
        when Messaging::States::VideoCapture::CaptureStates.stopped
          # cannot go directly from stopped to capturing - need to ready first
          success = false
        end

        return success
      end

      private
        def transitionFromReady
          # start ffmpeg
          @captureState.shellManager.ffmpegStart(@captureState.captureDetails.ffmpegOutFolder)

          @captureState.threadManager.start

          @captureState.setState(Messaging::States::VideoCapture::CaptureStates.capturing)

          true
        end

    end
  end
end
