require 'fileutils'

module States
  class ClientDetails
    attr_accessor :type, :hostname

    def initialize
    end

    def fromMessage(message)
      @type = Messaging::States::Storage::ClientTypes.new(message.type)
      @hostname = message.hostname
    end

    def reset
      @hostname = nil
    end
    def hasDetails?
      @hostname != nil && @hostname != ""
    end
  end
end
