module Handlers
  class FileOperations
    def initialize(header, message, storageState)
      @header = header
      @message = message
      @storageState = storageState
    end

    def handle
      returnHeader = Messaging::Messages::Header.dataFailure
      returnMessage = @message
      returnMessage.trace = "Couldn't complete file operations: Unknown reason"
      success = false

      # file operations
      requestedOp = Messaging::States::Storage::FileOperationTypes.new(@message.type)
      case requestedOp
      when Messaging::States::Storage::FileOperationTypes.put
        success, trace = @storageState.fileTransfer.get(
          @message.hostname,
          @message.clientFilePath,
          @message.serverFilePath
        )
      when Messaging::States::Storage::FileOperationTypes.get
        success, trace = @storageState.fileTransfer.put(
          @message.hostname,
          @message.serverFilePath,
          @message.clientFilePath
        )
      when Messaging::States::Storage::FileOperationTypes.delete
        success, trace = @storageState.fileTransfer.delete(@message.serverFilePath)
      when Messaging::States::Storage::FileOperationTypes.closeConnection
        success, trace = @storageState.fileTransfer.closeConnection(@message.hostname)
      end

      returnHeader = Messaging::Messages::Header.dataSuccess if success
      returnMessage.trace = trace

      return returnHeader, returnMessage
    end

    def canHandle?
      Messaging::Messages::Storage::FileOperations.new(nil).isSameType?(@message)
    end
  end
end
