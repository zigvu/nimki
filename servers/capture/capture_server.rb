#!/usr/bin/env ruby

require "bundler/setup"
require "messaging"

# require local files
curPath = File::expand_path('..', __FILE__)
curPathFiles = Dir["#{curPath}/*/**/*.rb"]
curPathFiles.each { |file| require_relative file }

# Start server
Messaging.logger.info("Start CaptureServer")

# # CaptureState is the global state storage
# @captureState = States::CaptureState.new
# # Handlers reply to requests from rasbari
# @captureHandler = Handlers::CaptureHandler.new(@captureState)
#
# # CaptureServer receives messages from rasbari and replies based on handlers
# @captureServer = Messaging.cache.video_capture.nimki.server(@captureHandler)
# # CaptureClient sends requests to rasbari and receives messages for further processing
# @captureClient = Messaging.cache.video_capture.nimki.client
#
#
# sleep 1000

@shellManager = ShellCommands::Manager.new
@shellManager.baseStart
@shellManager.vncStart
@shellManager.chromeStart('http://www.yahoo.com')

at_exit do
  @shellManager.stop
end


require "irb"
IRB.start
