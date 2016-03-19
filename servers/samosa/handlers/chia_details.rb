module Handlers
  class ChiaDetails
    def initialize(header, message, samosaState)
      @header = header
      @message = message
      @samosaState = samosaState
    end

    def handle
      returnHeader = Messaging::Messages::Header.dataSuccess
      returnMessage = @message

      @samosaState.operationType = Messaging::States::Samosa::OperationTypes.chia
      @samosaState.chiaDetails.fromMessage(@message)
      # ensure that rasbari server is alive
      status, trace = @samosaState.samosaClient.isRemoteAlive?
      if status
        # ensure that client can reach storage server
        status, trace = @samosaState.storageClient.isRemoteAlive?
        if status
          # kick off build process - just access starts new thread
          @samosaState.chiaBuildManager
          @samosaState.setState(Messaging::States::Samosa::ChiaStates.ready)

          returnHeader = Messaging::Messages::Header.dataSuccess
          trace = "Chia details set successfully"
        else
          trace = "Cannot ping storage server"
        end
      else
        trace = "Cannot ping rasbari server"
      end

      returnMessage.trace = trace
      return returnHeader, returnMessage
    end

    def canHandle?
      Messaging::Messages::Samosa::ChiaDetails.new(nil).isSameType?(@message)
    end
  end
end
