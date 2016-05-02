require 'fileutils'

module States
  class ChiaDetails
    attr_accessor :baseFolder, :iterationId, :chiaModelId
    attr_accessor :parentChiaModelId, :needsTempParent
    attr_accessor :storageHostname, :buildInputPath, :parentModelPath

    def initialize(baseFolder = nil)
      @baseFolder = baseFolder || '/tmp/chia'
      FileUtils.mkdir_p(@baseFolder)
    end

    def fromMessage(message)
      @iterationId = message.iterationId
      @chiaModelId = message.chiaModelId
      @parentChiaModelId = message.parentChiaModelId
      @needsTempParent = message.needsTempParent == "true"
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
