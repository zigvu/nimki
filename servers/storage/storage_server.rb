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
  opts.banner = "Usage: storage_server.rb [options]"

  opts.on('-f', '--fake_sftp true/false', 'If running the storage server in lcoal mode, set fake_sftp to true') do |o|
    options.fake_sftp = (o == 'true')
  end
end.parse!
@fakeSftp = options.fake_sftp

# Start server
Messaging.logger.info("Start StorageServer")
Messaging.logger.info("Fake SFTP storage mode") if @fakeSftp

# StorageState is the global state storage
@storageState = States::StorageState.new
@storageState.setFakeSftp if @fakeSftp

# Handlers reply to requests from others
@storageHandler = Handlers::StorageHandler.new(@storageState)

# StorageServer receives messages from others and replies based on handlers
@storageServer = Connections::StorageServer.new(@storageHandler)


at_exit do
  @storageState.reset
end

require "irb"
IRB.start
