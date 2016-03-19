require 'fileutils'

module States
  class KhajuriDetails
    attr_accessor :baseFolder, :storageHostname
    attr_accessor :iterationId

    def initialize(baseFolder = nil)
      @baseFolder = baseFolder || '/tmp/chia'
      FileUtils.mkdir_p(@baseFolder)
    end

    def fromMessage(message)
      # TODO: write
    end

    def reset
      @iterationId = nil
    end
    def hasDetails?
      @iterationId != nil && @iterationId != ""
    end
  end
end
