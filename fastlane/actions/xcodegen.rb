module Fastlane
  module Actions
    class XcodegenAction < Action
      def self.run(params)
        other_action.setup_local_bin

        binary_path = File.join(lane_context[SharedValues::LOCAL_BINARY_PATH], "xcodegen")

        unless File.exist?(binary_path)
          UI.message("Installing XcodeGen...")

          Actions.sh("curl -OL https://github.com/yonaskolb/XcodeGen/releases/download/2.25.0/xcodegen.zip")
          Actions.sh("unzip -q -o xcodegen.zip")
          Actions.sh("rm xcodegen.zip")
          Actions.sh("cp xcodegen/bin/xcodegen #{binary_path.shellescape}")
          Actions.sh("sh xcodegen/install.sh")
          Actions.sh("rm -rf xcodegen")
        end

        Actions.sh("#{binary_path.shellescape}")
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