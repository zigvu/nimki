module Handlers
  class PipelineResultsHandler
    def initialize(resultsQueue)
      @resultsQueue = resultsQueue
    end

    def call(header, message)
      returnHeader = Messaging::Messages::Header.dataSuccess
      returnMessage = message

      @resultsQueue << message

      trace = "Done"
      returnMessage.trace = trace
      return returnHeader, returnMessage
    end
  end
end
