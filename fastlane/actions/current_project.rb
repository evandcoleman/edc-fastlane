module Fastlane
  module Actions
    class CurrentProjectAction < Action
      def self.run(params)
        return File.expand_path(Dir["./*.xcodeproj"][0])
      end

      def self.description
        "Gets the current xcode project"
      end

      def self.authors
        ["evandcoleman"]
      end

      def self.is_supported?(platform)
        platform == :ios
      end
    end
  end
end