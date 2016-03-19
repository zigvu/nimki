require 'fileutils'

module States
  class ChiaDetails
    attr_accessor :baseFolder, :iterationId, :storageHostname
    attr_accessor :buildInputPath, :parentModelPath

    def initialize(baseFolder = nil)
      @baseFolder = baseFolder || '/tmp/chia'
      FileUtils.mkdir_p(@baseFolder)
    end

    def fromMessage(message)
      @iterationId = message.iterationId
      @storageHostname = message.storageHostname
      @buildInputPath = message.storageBuildInputPath
      @parentModelPath = message.storageParentModelPath
    end

    def reset
      @iterationId = nil
    end
    def hasDetails?
      @iterationId != nil && @iterationId != ""
    end
  end
end
