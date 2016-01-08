#!/usr/bin/env ruby

require "bundler/setup"
require "optparse"
require "fileutils"
require "messaging"

# require local files
curPath = File::expand_path('..', __FILE__)
curPathFiles = Dir["#{curPath}/*/**/*.rb"]
curPathFiles.each { |file| require_relative file }

options = OpenStruct.new
OptionParser.new do |opts|
  opts.banner = "Usage: storage_server.rb [options]"

  opts.on('-r', '--remote_ip IP', 'Remote IP or hostname') { |o| options.remote_ip = o }
end.parse!
raise "Missing argument: type '-h' for help." if !options.remote_ip
@remoteIp = options.remote_ip

# Start client
Messaging.logger.info("Start StorageClient")

@storageClientTest = Messaging::Connections::Clients::StorageClient.new(@remoteIp)

puts "Test: isRemoteAlive?"
puts @storageClientTest.isRemoteAlive?

puts "Test: Set client hostname in remote"
puts @storageClientTest.setClientDetails

clientNewFilePath = '/tmp/testStorageClient.txt'
serverFilePath = '/tmp/testStorage/testStorageClient.txt'
clientReceiveFilePath = '/tmp/testStorageClient2.txt'
File.open(clientNewFilePath, 'w') { |f| f.puts ('a'..'z').to_a.shuffle[0,100].join(" ") }

puts "Test: Save file to remote"
puts @storageClientTest.saveFile(clientNewFilePath, serverFilePath)

puts "Test: Save file from remote"
puts @storageClientTest.getFile(serverFilePath, clientReceiveFilePath)

puts "Test: Delete file on remote"
puts @storageClientTest.delete(serverFilePath)

puts "Test: Clean up files"
FileUtils.rm_rf(clientNewFilePath)
FileUtils.rm_rf(clientReceiveFilePath)

puts "Test: Done with all tests"

# require "irb"
# IRB.start
