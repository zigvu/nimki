#!/usr/bin/env ruby

require "bundler/setup"
require "messaging"
require_relative "capture_handler"


# currently assume default URL
connection = Messaging.connection
captureHandler = CaptureHandler.new
rpcServer = Connections::RpcServer.new(
  connection,
  'development.video.capture',
  'development.video.capture.nimki.a',
  captureHandler
)
rpcServer.start

sleep 1000
