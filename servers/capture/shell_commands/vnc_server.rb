module ShellCommands
  class VncServer
    # for debugging, make each commmand accessible from IRB
    attr_accessor :processRunner

    def initialize(displayId)
      @displayId = displayId
      @processRunner = ShellCommands::ProcessRunner.new(displayId)
    end

    def start
      # vnc server creates new process during run and after client disconnects,
      # the new process dies: hence, necessary to pkill existing server instances
      stop

      raise "VncServer process already exists" if @processRunner.isRunning?
      Messaging.logger.info("VncServer process starting")

      command = "export DISPLAY=:#{@displayId} && x11vnc -display :#{@displayId} -bg -nopw -listen localhost -xkb"
      @processRunner.start(command)
    end

    def stop
      @processRunner.stop("x11vnc")
    end

  end
end
