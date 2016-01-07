module Handlers
  class FileOperations
    def initialize(header, message, storageState)
      @header = header
      @message = message
      @storageState = storageState
    end

    def handle
      success = false
      traceback = "Couldn't complete file operations: Unknown reason"

      # file operations
      requestedOp = Messaging::States::Storage::FileOperationTypes.new(@message.type)
      case requestedOp
      when Messaging::States::Storage::FileOperationTypes.put
        success, traceback = @storageState.fileTransfer.get(
          @message.hostname,
          @message.clientFilePath,
          @message.serverFilePath
        )
      when Messaging::States::Storage::FileOperationTypes.get
        success, traceback = @storageState.fileTransfer.put(
          @message.hostname,
          @message.serverFilePath,
          @message.clientFilePath
        )
      when Messaging::States::Storage::FileOperationTypes.delete
        success, traceback = @storageState.fileTransfer.put(@message.serverFilePath)
      end

      if success
        returnHeader = Messaging::Messages::Header.dataSuccess
      else
        returnHeader = Messaging::Messages::Header.dataFailure
      end

      @message.traceback = traceback
      returnMessage = @message
      return returnHeader, returnMessage
    end

    def canHandle?
      Messaging::Messages::Storage::FileOperations.new(nil).isSameType?(@message)
    end
  end
end
