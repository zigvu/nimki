module ShellCommands
  class Chrome
    # for debugging, make each commmand accessible from IRB
    attr_accessor :processRunner

    def initialize(displayId)
      @displayId = displayId
      @processRunner = ShellCommands::ProcessRunner.new(displayId)
    end

    def start(captureUrl)
      raise "Chrome process already exists" if @processRunner.isRunning?
      Messaging.logger.info("Chrome process starting")

      command = "export DISPLAY=:99 && google-chrome-stable --app=#{captureUrl}"
      @processRunner.start(command)
    end

    def stop
      @processRunner.stop("google-chrome-stable")
    end

  end
end
