module ShellCommands
  class Manager
    # for debugging, make each commmand accessible from IRB
    attr_accessor :xvfb, :fluxbox, :vncServer, :chrome, :ffmpeg

    def initialize
      displayId = 99
      width = 1280
      height = 720

      @xvfb = ShellCommands::Xvfb.new(displayId, width, height)
      @fluxbox = ShellCommands::Fluxbox.new(displayId)
      @vncServer = ShellCommands::VncServer.new(displayId)
      @chrome = ShellCommands::Chrome.new(displayId)
      @ffmpeg = ShellCommands::Ffmpeg.new(displayId, width, height)

      @setupSleepTime = 5 # seconds
    end

    def baseStart
      @xvfb.start
      sleep @setupSleepTime
      @fluxbox.start
      sleep @setupSleepTime
    end
    def baseStop
      # exit in correct order
      @fluxbox.stop
      sleep @setupSleepTime
      @xvfb.stop
      sleep @setupSleepTime
    end

    def vncStart
      @vncServer.start
      sleep @setupSleepTime
    end
    def vncStop
      @vncServer.stop
      sleep @setupSleepTime
    end

    def chromeStart(url)
      @chrome.start(url)
      sleep @setupSleepTime
    end
    def chromeStop
      @chrome.stop
      sleep @setupSleepTime
    end

    def ffmpegStart(saveFolder)
      @ffmpeg.start(saveFolder)
      sleep @setupSleepTime
    end
    def ffmpegStop
      @ffmpeg.stop
      sleep @setupSleepTime
    end

    def stop
      ffmpegStop
      chromeStop
      vncStop
      baseStop
    end

  end
end
