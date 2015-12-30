module ShellCommands
  class ProcessRunner
    attr_accessor :pid

    def initialize(displayId)
      @pid = nil
      @envVars = {
        "DISPLAY" => "#{displayId}"
      }
      @processOptions = {
        STDERR=>STDOUT
      }
      @processWaitTimeAfterStart = 5 # seconds
      @processWaitTimeAfterEnd = 2 # seconds
    end

    def isRunning?
      @pid != nil
    end

    def start(command)
      @pid = Process.spawn(@envVars, command, @processOptions)
      Process.detach @pid
      sleep @processWaitTimeAfterStart
    end

    def stop(pkillCommandName = nil)
      begin
        `sudo pkill "#{pkillCommandName}"` if pkillCommandName
        Process.kill("KILL", @pid) if isRunning?
      rescue
        Messaging.logger.warn("Process (#{@pid}) already killed")
      end
      @pid = nil
      sleep @processWaitTimeAfterEnd
    end

  end
end
