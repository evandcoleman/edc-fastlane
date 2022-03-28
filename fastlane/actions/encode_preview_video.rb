module Fastlane
  module Actions
    class EncodePreviewVideoAction < Action
      def self.run(params)
        input_path = params[:input_path]
        output_path = params[:output_path]

        if output_path.nil?
          filename = File.basename(input_path, ".*")
          output_path = File.join(File.expand_path("..", input_path), "#{filename}_encoded.mp4")
        end

        Actions.sh("which ffmpeg", log: false, error_callback: proc do |error_output|
          UI.user_error!("ffmpeg is required to use this action.")
        end)

        args = []
        args << "ffmpeg"
        if params[:silence_audio]
          args << "-f lavfi"
          args << "-i anullsrc=channel_layout=stereo:sample_rate=44100"
        end
        args << "-i"
        args << input_path.shellescape
        args << "-shortest"
        args << "-vf scale=#{params[:width]}:#{params[:height]},setsar=1,fps=30#{params[:rotate] ? ",transpose=1" : ""}"
        if params[:silence_audio]
          args << "-c:a aac"
        else
          args << "-c:a copy"
        end
        args << "-f mp4"
        args << output_path.shellescape

        Actions.sh(args.join(" "))
      end

      def self.description
        "Encodes an app preview video for upload to Apple"
      end

      def self.authors
        ["evandcoleman"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :input_path,
                                       description: "Path to input video",
                                       optional: false),
          FastlaneCore::ConfigItem.new(key: :silence_audio,
                                      description: "If true, replaces the audio with silence",
                                      default_value: true,
                                      is_string: false,
                                      optional: true),
          FastlaneCore::ConfigItem.new(key: :width,
                                      description: "The output width",
                                      default_value: "886"),
          FastlaneCore::ConfigItem.new(key: :height,
                                      description: "The output height",
                                      default_value: "1920"),
          FastlaneCore::ConfigItem.new(key: :rotate,
                                      description: "If true video is rotate 90 degrees",
                                      is_string: false,
                                      default_value: false),
          FastlaneCore::ConfigItem.new(key: :output_path,
                                      description: "The path to output the video (defaults to the directory of the input)",
                                      optional: true),
        ]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end