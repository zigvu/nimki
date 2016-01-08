require 'fileutils'

module Connections
  class FileTransfer

    def initialize(connectionsCache)
      @cache = connectionsCache
    end

    def get(fromHost, clientFilePath, serverFilePath)
      messageWrapper(fromHost, serverFilePath) do
        @cache.get(fromHost).download!(clientFilePath, serverFilePath)
      end
    end

    def put(toHost, serverFilePath, clientFilePath)
      messageWrapper(toHost, serverFilePath) do
        @cache.get(toHost).upload!(serverFilePath, clientFilePath)
      end
    end

    def delete(serverFilePath)
      messageWrapper(nil, serverFilePath) do
        FileUtils.rm(serverFilePath)
      end
    end

    def closeConnection(hostname)
      @cache.stop(hostname)
    end

    private
      def messageWrapper(hostname, serverFilePath)
        success = true
        message = "File operation successful: #{serverFilePath}"
        begin
          yield
        rescue StandardError => e
          success = false
          message = "#{e}"
          @cache.restart(hostname) if hostname
          Messaging.logger.warn("FileTransfer: #{e}")
        end
        return success, message
      end

  end
end
