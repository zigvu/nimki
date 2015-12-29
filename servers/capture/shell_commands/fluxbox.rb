module ShellCommands
  class Fluxbox
    # for debugging, make each commmand accessible from IRB
    attr_accessor :processRunner

    def initialize(displayId)
      @displayId = displayId
      @processRunner = ShellCommands::ProcessRunner.new(displayId)
    end

    def start
      raise "Fluxbox process already exists" if @processRunner.isRunning?
      Messaging.logger.info("Fluxbox process starting")

      command = "export DISPLAY=:#{@displayId} && fluxbox"
      @processRunner.start(command)
    end

    def stop
      @processRunner.stop("fluxbox")
    end

  end
end
