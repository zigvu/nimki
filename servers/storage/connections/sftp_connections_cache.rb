require 'net/sftp'

module Connections
  class SftpConnectionsCache

    class Sftp
      def initialize(hostname)
        @sftp = Net::SFTP.start(hostname, "ubuntu")
      end

      def download!(clientFilePath, serverFilePath)
        # ensure that local path exists
        FileUtils.mkdir_p(File.dirname(serverFilePath))
        @sftp.download!(clientFilePath, serverFilePath)
        true
      end

      def upload!(serverFilePath, clientFilePath)
        # ensure that remote path exists
        splitPath = File.dirname(clientFilePath).split("/")
        splitPath.each_with_index do |sp, idx|
          next if idx == 1
          remotePath = splitPath[0..idx].join("/")
          next if remotePath == ""

          begin
            @sftp.mkdir! remotePath
          rescue Net::SFTP::StatusException => e
            # ignore directory already exists code
            raise if e.code != 4
          end
        end
        # once path exists, save
        @sftp.upload!(serverFilePath, clientFilePath)
        true
      end
    end

    def initialize
      # format:
      # {hostname: {connection: sftpConnection, last_accessed: time}, }
      @cache = {}
      @timeForReset = 10 * 60 # 10 minutes
    end

    def get(hostname)
      if !@cache[hostname] || (Time.now - @cache[hostname][:last_accessed] > @timeForReset)
        start(hostname)
      end
      @cache[hostname][:connection]
    end

    def restart(hostname)
      stop(hostname)
      start(hostname)
    end

    def start(hostname)
      Messaging.logger.info("(re)Start SFTP connetion to #{hostname}")
      @cache[hostname] = {}
      @cache[hostname][:connection] = Sftp.new(hostname)
      @cache[hostname][:last_accessed] = Time.now
    end

    def stop(hostname)
      Messaging.logger.info("Stop SFTP connetion to #{hostname}")
      @cache.delete(hostname)
      true
    end

    def stopAll
      @cache.each do |hostname, _|
        stop(hostname)
      end
      true
    end

  end
end
