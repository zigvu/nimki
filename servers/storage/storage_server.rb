#!/usr/bin/env ruby

require "bundler/setup"
require "optparse"
require "messaging"

# require local files
curPath = File::expand_path('..', __FILE__)
curPathFiles = Dir["#{curPath}/*/**/*.rb"]
curPathFiles.each { |file| require_relative file }

# Start server
Messaging.logger.info("Start StorageServer")

# StorageState is the global state storage
@storageState = States::StorageState.new

# Handlers reply to requests from others
@storageHandler = Handlers::StorageHandler.new(@storageState)

# StorageServer receives messages from others and replies based on handlers
@storageServer = Connections::StorageServer.new(@storageHandler)


at_exit do
  @storageState.reset
end

require "irb"
IRB.start
