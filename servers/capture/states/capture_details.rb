require 'fileutils'

module States
  class CaptureDetails
    attr_accessor :url, :width, :height, :workflowId
    attr_accessor :localFileFolder, :rasbariRequestedFileFolder

    def initialize(baseFolder = nil)
      @baseFolder = baseFolder || '/tmp/capture'
    end

    def fromMessage(message)
      @url = message.url
      @width = message.width
      @height = message.height
      @workflowId = message.workflowId


      @localFileFolder = "#{@baseFolder}/#{@workflowId}/local"
      FileUtils.rm_rf(@localFileFolder)
      FileUtils.mkdir_p(@localFileFolder)
      @rasbariRequestedFileFolder = "#{@baseFolder}/#{@workflowId}/rasbari"
      FileUtils.mkdir_p(@rasbariRequestedFileFolder)
      FileUtils.rm_rf(@rasbariRequestedFileFolder)
    end

    def reset
      @workflowId = nil
    end
    def hasDetails?
      @workflowId != nil && @workflowId != ""
    end
  end
end
