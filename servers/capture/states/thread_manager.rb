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
        Messaging.logger.debug("Ffmpeg queue not empty - sleeping")
        sleep 10
      end
    end

    private

      def threadRasbariQuery
        Messaging.logger.debug("Starting rasbari files thread")
        Thread.new do
          while true
            # block if no file has been produced
            clipFileName = @queueClipFileNames.pop
            # break if poison pill
            break if clipFileName == false

            thumbnailFileName = getThumbnailFileName(clipFileName)
            # send rasbariServer a request
            clipDetailsStatus, clipDetailsMessage = @captureClient.getClipDetails(@captureId, clipFileName)
            if clipDetailsStatus
              # parse save url from response
              clipId = clipDetailsMessage.clipId
              storageClipPath = clipDetailsMessage.storageClipPath
              storageThumbnailPath = clipDetailsMessage.storageThumbnailPath
              # send request to storage server to save files
              storeClipSuccess, _ = @storageClient.saveFile(clipFileName, storageClipPath)
              storeThumbnailSuccess, _ = @storageClient.saveFile(thumbnailFileName, storageThumbnailPath)

              if storeClipSuccess && storeThumbnailSuccess
                Messaging.logger.debug("Storage saved: Clip id: #{clipId}")
              else
                # TODO: send message to rasbari with reason
                Messaging.logger.error("Storage error: Clip id: #{clipId}")
              end # if storeSuccess

              # delete both files regardless of whether they were saved
              FileUtils.rm_rf(clipFileName)
              FileUtils.rm_rf(thumbnailFileName)
            else
              Messaging.logger.error("Clip details error: Filename: #{clipFileName}")
            end # if storeSuccess
          end # while
        end # Thread
      end

      def threadFfmpegFiles
        Messaging.logger.debug("Starting ffmpeg files thread")
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
                Messaging.logger.debug("FFMpeg created: #{clipFileName}")
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
