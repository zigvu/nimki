require 'fileutils'

module States
  class CaptureDetails
    attr_accessor :captureId, :captureUrl, :width, :height
    attr_accessor :playbackFrameRate, :storageHostname
    attr_accessor :ffmpegOutFolder, :rasbariRequestedFolder

    def initialize(baseFolder = nil)
      @baseFolder = baseFolder || '/tmp/capture'
    end

    def fromMessage(message)
      @captureId = message.captureId
      @captureUrl = message.captureUrl
      @width = message.width
      @height = message.height
      @playbackFrameRate = message.playbackFrameRate
      @storageHostname = message.storageHostname


      @ffmpegOutFolder = "#{@baseFolder}/#{@captureId}/ffmpeg"
      FileUtils.rm_rf(@ffmpegOutFolder)
      FileUtils.mkdir_p(@ffmpegOutFolder)
      @rasbariRequestedFolder = "#{@baseFolder}/#{@captureId}/rasbari"
      FileUtils.rm_rf(@rasbariRequestedFolder)
      FileUtils.mkdir_p(@rasbariRequestedFolder)
    end

    def reset
      @captureId = nil
    end
    def hasDetails?
      @captureId != nil && @captureId != ""
    end
  end
end
