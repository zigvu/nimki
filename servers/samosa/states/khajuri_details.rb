require 'json'
require 'fileutils'

module States
  class KhajuriDetails
    attr_accessor :baseFolder, :storageHostname
    attr_accessor :capEvalId, :chiaModelId, :testInputPath, :modelPath, :clipIds

    def initialize(baseFolder = nil)
      @baseFolder = baseFolder || '/tmp/khajuri'
      FileUtils.mkdir_p(@baseFolder)
    end

    def fromMessage(message)
      @capEvalId = message.capEvalId
      @chiaModelId = message.chiaModelId
      @storageHostname = message.storageHostname
      @testInputPath = message.storageTestInputPath
      @modelPath = message.storageModelPath
      @clipIds = JSON.parse(message.clipIds).map{ |cl| cl.to_i }.sort
    end

    def reset
      @capEvalId = nil
    end
    def hasDetails?
      @capEvalId != nil && @capEvalId != ""
    end
  end
end
