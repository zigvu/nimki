require 'fileutils'

module Connections
  class FileTransfer

    def initialize(connectionsCache)
      @cache = connectionsCache
    end

    def get(fromHost, clientFilePath, serverFilePath)
      traceWrapper(fromHost, serverFilePath) do
        @cache.get(fromHost).download!(clientFilePath, serverFilePath)
      end
    end

    def put(toHost, serverFilePath, clientFilePath)
      traceWrapper(toHost, serverFilePath) do
        @cache.get(toHost).upload!(serverFilePath, clientFilePath)
      end
    end

    def delete(serverFilePath)
      traceWrapper(nil, serverFilePath) do
        FileUtils.rm(serverFilePath)
      end
    end

    def closeConnection(hostname)
      @cache.stop(hostname)
    end

    private
      def traceWrapper(hostname, serverFilePath)
        success = true
        trace = "File operation successful: #{serverFilePath}"
        begin
          yield
        rescue StandardError => e
          success = false
          trace = "Error: #{e.backtrace.first}"
          @cache.restart(hostname) if hostname
          Messaging.logger.error(e)
        end
        return success, trace
      end

  end
end
