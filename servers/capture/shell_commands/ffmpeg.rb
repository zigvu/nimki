module ShellCommands
  class Ffmpeg
    # for debugging, make each commmand accessible from IRB
    attr_accessor :processRunner

    def initialize(displayId, width, height)
      @displayId = displayId
      @width = width
      @height = height
      @processRunner = ShellCommands::ProcessRunner.new(displayId)
    end

    def start(saveFolder)
      raise "Ffmpeg process already exists" if @processRunner.isRunning?
      Messaging.logger.info("Ffmpeg process starting")

      command = "export DISPLAY=:#{@displayId} && ffmpeg -loglevel error -framerate 25 -video_size #{@width}x#{@height} -f x11grab -i :#{@displayId}.0+0,0 -c:v libx264 -pix_fmt yuv420p -crf 20 -preset veryfast -f segment -segment_time 60 -reset_timestamps 1 #{saveFolder}/capture%02d.mp4"
      @processRunner.start(command)
    end

    def stop
      @processRunner.stop("ffmpeg")
    end

  end
end
