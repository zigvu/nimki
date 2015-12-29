module ShellCommands
  class Xvfb
    # for debugging, make each commmand accessible from IRB
    attr_accessor :processRunner

    def initialize(displayId, width, height)
      @displayId = displayId
      @width = width
      @height = height
      @processRunner = ShellCommands::ProcessRunner.new(displayId)
    end

    def start
      raise "Xvfb process already exists" if @processRunner.isRunning?
      Messaging.logger.info("Xvfb process starting")

      command = "export DISPLAY=:#{@displayId} && sudo Xvfb :#{@displayId} -screen 0 #{@width}x#{@height}x24"
      @processRunner.start(command)
    end

    def stop
      @processRunner.stop("Xvfb")
    end

  end
end
