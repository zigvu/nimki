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
    end

    def baseStart
      @xvfb.start
      @fluxbox.start
    end
    def baseStop
      # exit in correct order
      @fluxbox.stop
      @xvfb.stop
    end

    def vncStart
      @vncServer.start
    end
    def vncStop
      @vncServer.stop
    end

    def chromeStart(url)
      @chrome.start(url)
    end
    def chromeStop
      @chrome.stop
    end

    def ffmpegStart(saveFolder)
      @ffmpeg.start(saveFolder)
    end
    def ffmpegStop
      @ffmpeg.stop
    end

    def stop
      ffmpegStop
      chromeStop
      vncStop
      baseStop
    end

  end
end
