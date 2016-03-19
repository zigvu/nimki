#!/usr/bin/env ruby

require "bundler/setup"
require "messaging"

# require local files
curPath = File::expand_path('..', __FILE__)
curPathFiles = Dir["#{curPath}/*/**/*.rb"]
curPathFiles.each { |file| require_relative file }

# Start server
Messaging.logger.info("Start SamosaServer")

# SamosaState is the global state for samosa
@samosaState = States::SamosaState.new

# Handlers reply to requests from others
@samosaHandler = Handlers::SamosaHandler.new(@samosaState)

# SamosaServer receives messages from others and replies based on handlers
@samosaServer = Connections::SamosaServer.new(@samosaHandler)

at_exit do
  @samosaState.reset
end

require "irb"
IRB.start
