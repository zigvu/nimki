require "thread"
require "fileutils"

module States
  class ThreadManager
    attr_accessor :queueRasbariFiles

    def initialize
      @queueRasbariFiles = Queue.new
    end

    def start(ffmpegOutFolder, rasbariRequestedFolder, captureClient, storageClient)
      reset
      @poisonThreadFfmpegFiles = false

      threadFfmpegFiles(ffmpegOutFolder, rasbariRequestedFolder)
      threadRasbariQuery(captureClient, storageClient)
    end

    def reset
      @poisonThreadFfmpegFiles = true

      # until the queue is empty, do not return
      while !@queueRasbariFiles.empty?
        Messaging.logger.debug("Ffmpeg queue not empty - sleeping")
        sleep 10
      end
    end

    private

      def threadRasbariQuery(captureClient, storageClient)
        Thread.new do
          while true
            # block if no file has been produced
            rasbariFile = @queueRasbariFiles.pop
            # break if poison pill
            break if rasbariFile == false

            Messaging.logger.debug("RasbariQuery: Query for: #{rasbariFile}")
            # send rasbariServer a request
            # parse save url from response
            # send storageSerer a request
            # parse OK response
            # delete local file
          end
        end
      end

      def threadFfmpegFiles(ffmpegOutFolder, rasbariRequestedFolder)
        Thread.new do
          while true
            # look at number of files - listed by last modified flag
            ffmpegFiles = Dir["#{ffmpegOutFolder}/*"].sort_by{ |f| File.mtime(f) }
            # ignore last file being produced if condition to end
            if @poisonThreadFfmpegFiles && ffmpegFiles.length < 2
              # put poison pill for downstream threads
              @queueRasbariFiles << false
              break
            end
            # if at least 2 files, copy all but the latest file
            if ffmpegFiles.length > 1
              # if not ending, move files and put in queue
              ffmpegFiles.each_with_index do |f, idx|
                break if idx > ffmpegFiles.length - 2
                rasbariFile = "#{rasbariRequestedFolder}/#{File.basename(f)}"
                FileUtils.mv(f, rasbariFile)
                @queueRasbariFiles << rasbariFile
                Messaging.logger.debug("FfmpegFiles: Moving to: #{rasbariFile}")
              end
            end
            # sleep 5 seconds
            sleep 5
          end # end while
        end # end Thread
      end

  end
end
