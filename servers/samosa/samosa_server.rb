#!/usr/bin/env ruby

require "bundler/setup"
require "optparse"
require "messaging"

# require local files
curPath = File::expand_path('..', __FILE__)
curPathFiles = Dir["#{curPath}/*/**/*.rb"]
curPathFiles.each { |file| require_relative file }

options = OpenStruct.new
OptionParser.new do |opts|
  opts.banner = "Usage: samosa_server.rb [options]"

  opts.on('-f', '--fake_gpu true/false', 'If running the samosa server in non-gpu machine, set fake_gpu to true') do |o|
    options.fake_gpu = (o == 'true')
  end
end.parse!
@fakeGpu = options.fake_gpu || false

# Start server
Messaging.logger.info("Start SamosaServer")
Messaging.logger.info("Fake GPU mode") if @fakeGpu

# SamosaState is the global state for samosa
@samosaState = States::SamosaState.new
@samosaState.fakeGpu = @fakeGpu

# Handlers reply to requests from others
@samosaHandler = Handlers::SamosaHandler.new(@samosaState)

# SamosaServer receives messages from others and replies based on handlers
@samosaServer = Connections::SamosaServer.new(@samosaHandler)

at_exit do
  @samosaState.reset
end

require "irb"
IRB.start
