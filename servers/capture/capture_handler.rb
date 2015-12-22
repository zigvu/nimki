class CaptureHandler < Handlers::RpcHandler
  def call(header, payload)
    # see if generic handler can handle
    handled, returnHeader, returnMessage = handleGeneric(header)
    if handled
      return returnHeader, returnMessage
    end

    # else, need to specify cases

    return {}, "Hello"
  end
end
