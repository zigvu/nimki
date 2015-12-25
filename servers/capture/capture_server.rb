#!/usr/bin/env ruby

require "bundler/setup"
require "messaging"

curPath = File::expand_path('..', __FILE__)
curPathFiles = Dir["#{curPath}/**/*.rb"]
curPathFiles.each { |file|
  require_relative file
}

Messaging.logger.info("Start CaptureServer")

@captureState = CaptureState.new
@bufferManager = BufferManager.new(@captureState)

@captureHandler = CaptureHandler.new(@bufferManager)
@captureServer = Messaging.cache.video_capture.nimki.server(@captureHandler)
@captureClient = Messaging.cache.video_capture.nimki.client


# sleep 1000

require "irb"
IRB.start
