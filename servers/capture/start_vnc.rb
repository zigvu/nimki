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
  opts.banner = "Usage: start_vnc.rb [options]"

  opts.on('-r', '--remote_ip IP', 'Remote IP or hostname (local for test)') { |o| options.remote_ip = o }
end.parse!
raise "Missing argument: type '-h' for help." if !options.remote_ip
@remoteIp = options.remote_ip

# Start client
Messaging.logger.info("Start CaptureClient")

# if testing in local machine, no need to ssh
if @remoteIp != 'local'
  # Start ssh connection
  sshConnectionCmd = "ssh -N -T -L 5900:localhost:5900 ubuntu@#{@remoteIp}"
  @sshConnectionPid = Process.spawn(sshConnectionCmd)
  Process.detach @sshConnectionPid
end

# Start vnc client
vncClientCmd = "vncviewer -encodings 'copyrect tight hextile' localhost:5900"
@vncClientPid = Process.spawn(vncClientCmd)

Messaging.logger.info("Play video in browser and maximize player prior to closing vnc client")

Process.waitpid @vncClientPid

Messaging.logger.info("Finished CaptureClient")
