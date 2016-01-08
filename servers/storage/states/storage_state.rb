module States
  class StorageState
    attr_accessor :_clientDetails, :_sftpConnectionsCache, :_fileTransfer

    def initialize
      @fakeSftp = false
    end

    def setFakeSftp
      @fakeSftp = true
    end
    def fakeSftp?
      @fakeSftp
    end

    def clientDetails
      @_clientDetails ||= States::ClientDetails.new
    end

    def sftpConnectionsCache
      if !@_sftpConnectionsCache
        if fakeSftp?
          Messaging.logger.info("Running fake sftp for local mode")
          @_sftpConnectionsCache = Connections::FakeSftpConnectionsCache.new
        else
          @_sftpConnectionsCache = Connections::SftpConnectionsCache.new
        end
      end
      @_sftpConnectionsCache
    end

    def fileTransfer
      @_fileTransfer ||= Connections::FileTransfer.new(sftpConnectionsCache)
    end

    # reset in orderly fashion
    def reset
      @_sftpConnectionsCache.stopAll if @_sftpConnectionsCache
      @_clientDetails.reset if @_clientDetails
    end

  end
end
