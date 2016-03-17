require 'fileutils'

module States
  class ClientDetails
    attr_accessor :hostname

    def initialize
    end

    def fromMessage(message)
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
