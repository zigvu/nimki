require 'fileutils'

# Proxy class for testing scp in local environment
module Connections
  class FakeSftpConnectionsCache

    class FakeSftp
      def download!(clientFilePath, serverFilePath)
        if clientFilePath != serverFilePath
          FileUtils.mkdir_p(File.dirname(serverFilePath))
          FileUtils.cp(clientFilePath, serverFilePath)
        end
        true
      end

      def upload!(serverFilePath, clientFilePath)
        if serverFilePath != clientFilePath
          FileUtils.mkdir_p(File.dirname(clientFilePath))
          FileUtils.cp(serverFilePath, clientFilePath)
        end
        true
      end
    end

    def initialize
      @fakeSftp = FakeSftp.new
    end

    def get(hostname)
      @fakeSftp
    end

    def restart(hostname)
      # no op
      true
    end

    def start(hostname)
      # no op
      true
    end

    def stop(hostname)
      # no op
      true
    end

    def stopAll
      # no op
      true
    end

  end
end
