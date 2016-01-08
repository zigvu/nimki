#!/usr/bin/env ruby

require "bundler/setup"
require "messaging"

# require local files
curPath = File::expand_path('..', __FILE__)
curPathFiles = Dir["#{curPath}/*/**/*.rb"]
curPathFiles.each { |file| require_relative file }

# Start server
Messaging.logger.info("Start CaptureServer")

# because Xvfb shell command requires sudo, ensure that sudo can be used
`sudo ls -lrt`

# CaptureState is the global state storage
@captureState = States::CaptureState.new

# Handlers reply to requests from rasbari
@captureHandler = Handlers::CaptureHandler.new(@captureState)

# CaptureServer receives messages from rasbari and replies based on handlers
@captureServer = Connections::CaptureServer.new(@captureHandler)

at_exit do
  @captureState.reset
end


require "irb"
IRB.start
