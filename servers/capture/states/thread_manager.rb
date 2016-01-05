require "thread"
require "fileutils"

module States
  class ThreadManager
    attr_accessor :queueRasbariFiles

    def initialize
      @queueRasbariFiles = Queue.new
    end

    def setClients(captureClient, storageClient)
      @captureClient = captureClient
      @storageClient = storageClient
    end

    def setCaptureDetails(captureDetails)
      @captureId = captureDetails.captureId
      @ffmpegOutFolder = captureDetails.ffmpegOutFolder
      @rasbariRequestedFolder = captureDetails.rasbariRequestedFolder
    end

    def start
      reset
      @poisonThreadFfmpegFiles = false

      threadFfmpegFiles(@ffmpegOutFolder, @rasbariRequestedFolder)
      threadRasbariQuery(@captureId, @captureClient, @storageClient)
    end

    def reset
      @poisonThreadFfmpegFiles = true

      # until the queue is empty, do not return
      while !@queueRasbariFiles.empty?
        Messaging.logger.debug("ThreadManager: Ffmpeg queue not empty - sleeping")
        sleep 10
      end
    end

    private

      def threadRasbariQuery(captureId, captureClient, storageClient)
        Thread.new do
          while true
            # block if no file has been produced
            rasbariFile = @queueRasbariFiles.pop
            # break if poison pill
            break if rasbariFile == false

            # send rasbariServer a request
            message = captureClient.getClipDetails(captureId, rasbariFile)
            # parse save url from response
            clipId = message.clipId
            storageUrl = message.storageUrl
            # TODO: send storageSerer a request
            # parse OK response
            # delete local file
            Messaging.logger.debug("ThreadManager: Saved: #{rasbariFile} with clip id: #{clipId} ")
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
              # if not ending, move file, create thumbnail and put in queue
              ffmpegFiles.each_with_index do |f, idx|
                break if idx > ffmpegFiles.length - 2
                rasbariFile = "#{rasbariRequestedFolder}/#{File.basename(f)}"
                thumbnailFile = "#{rasbariRequestedFolder}/#{File.basename(f, '.*')}.jpg"
                FileUtils.mv(f, rasbariFile)
                `ffmpeg -loglevel panic -ss 0 -i "#{rasbariFile}" -frames:v 1 "#{thumbnailFile}"`
                @queueRasbariFiles << rasbariFile
                Messaging.logger.debug("ThreadManager: FFMpeg created: #{rasbariFile}")
              end
            end
            # sleep 5 seconds
            sleep 5
          end # end while
        end # end Thread
      end

  end
end
