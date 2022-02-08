module Fastlane
  module Actions
    class XcodegenAction < Action
      def self.run(params)
        Actions.sh("which xcodegen", log: false, error_callback: proc do |error_output|
          UI.message("Installing XcodeGen...")

          Actions.sh("curl -OL https://github.com/yonaskolb/XcodeGen/releases/download/2.25.0/xcodegen.zip")
          Actions.sh("unzip -q -o xcodegen.zip")
          Actions.sh("rm xcodegen.zip")
          Actions.sh("xcodegen/install.sh")
          Actions.sh("rm -rf xcodegen")
        end)

        Actions.sh("/usr/local/bin/xcodegen")
      end

      def self.description
        "Installs and runs XcodeGen"
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