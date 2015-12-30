require 'fileutils'

module States
  class CaptureDetails
    attr_accessor :url, :width, :height, :workflowId
    attr_accessor :ffmpegOutFolder, :rasbariRequestedFolder

    def initialize(baseFolder = nil)
      @baseFolder = baseFolder || '/tmp/capture'
    end

    def fromMessage(message)
      @url = message.url
      @width = message.width
      @height = message.height
      @workflowId = message.workflowId


      @ffmpegOutFolder = "#{@baseFolder}/#{@workflowId}/ffmpeg"
      FileUtils.rm_rf(@ffmpegOutFolder)
      FileUtils.mkdir_p(@ffmpegOutFolder)
      @rasbariRequestedFolder = "#{@baseFolder}/#{@workflowId}/rasbari"
      FileUtils.mkdir_p(@rasbariRequestedFolder)
      FileUtils.rm_rf(@rasbariRequestedFolder)
    end

    def reset
      @workflowId = nil
    end
    def hasDetails?
      @workflowId != nil && @workflowId != ""
    end
  end
end
