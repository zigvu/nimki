require "thread"
require "fileutils"

module States
  class ThreadManager
    attr_accessor :queueClipFileNames # for debugging

    def initialize
      @queueClipFileNames = Queue.new
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

      threadFfmpegFiles
      threadRasbariQuery
    end

    def reset
      @poisonThreadFfmpegFiles = true

      # until the queue is empty, do not return
      while !@queueClipFileNames.empty?
        Messaging.logger.debug("ThreadManager: Ffmpeg queue not empty - sleeping")
        sleep 10
      end
    end

    private

      def threadRasbariQuery
        Messaging.logger.debug("ThreadManager: Starting rasbari files thread")
        Thread.new do
          while true
            # block if no file has been produced
            clipFileName = @queueClipFileNames.pop
            # break if poison pill
            break if clipFileName == false

            thumbnailFileName = getThumbnailFileName(clipFileName)
            # send rasbariServer a request
            message = @captureClient.getClipDetails(@captureId, clipFileName)
            # parse save url from response
            clipId = message.clipId
            storageClipPath = message.storageClipPath
            storageThumbnailPath = message.storageThumbnailPath
            # send request to storage server to save files
            storeSuccess = (
              @storageClient.saveFile(clipFileName, storageClipPath) &&
              @storageClient.saveFile(thumbnailFileName, storageThumbnailPath)
            )

            if storeSuccess
              FileUtils.rm_rf(clipFileName)
              FileUtils.rm_rf(thumbnailFileName)
              Messaging.logger.debug("ThreadManager: Storage saved: Clip id: #{clipId}")
            else
              Messaging.logger.error("ThreadManager: Storage error: Clip id: #{clipId}")
            end

            Messaging.logger.debug("ThreadManager: Storage saved: Clip id: #{clipId}")
          end # while
        end # Thread
      end

      def threadFfmpegFiles
        Messaging.logger.debug("ThreadManager: Starting ffmpeg files thread")
        Thread.new do
          while true
            # look at number of files - listed by last modified flag
            ffmpegFiles = Dir["#{@ffmpegOutFolder}/*"].sort_by{ |f| File.mtime(f) }
            # ignore last file being produced if condition to end
            if @poisonThreadFfmpegFiles && ffmpegFiles.length < 2
              # put poison pill for downstream threads
              @queueClipFileNames << false
              break
            end
            # if at least 2 files, copy all but the latest file
            if ffmpegFiles.length > 1
              ffmpegFiles.each_with_index do |f, idx|
                break if idx > ffmpegFiles.length - 2

                # move clip
                clipFileName = "#{@rasbariRequestedFolder}/#{File.basename(f)}"
                FileUtils.mv(f, clipFileName)

                # create thumbnail
                thumbnailFileName = getThumbnailFileName(clipFileName)
                `ffmpeg -loglevel panic -ss 0 -i "#{clipFileName}" -frames:v 1 "#{thumbnailFileName}"`

                # put in queue
                @queueClipFileNames << clipFileName
                Messaging.logger.debug("ThreadManager: FFMpeg created: #{clipFileName}")
              end
            end
            # sleep 5 seconds
            sleep 5
          end # end while
        end # end Thread
      end

      def getThumbnailFileName(clipFileName)
        "#{File.dirname(clipFileName)}/#{File.basename(clipFileName, '.*')}.jpg"
      end

  end
end
