module Fastlane
  module Actions
    class XctesthtmlreportAction < Action
      def self.run(params)
        other_action.setup_local_bin

        binary_path = File.join(lane_context[SharedValues::LOCAL_BINARY_PATH], "xchtmlreport")

        unless File.exist?(binary_path)
          UI.message("Installing xchtmlreport...")

          release = other_action.get_latest_release(repo: "XCTestHTMLReport/XCTestHTMLReport")
          assets = release["assets"]
          arch = RUBY_PLATFORM.split("-")[0]
          asset = assets.find { |a| a["name"].include? arch }
          url = asset["browser_download_url"]

          Actions.sh("curl -L -o xchtmlreport.zip #{url}")
          Actions.sh("unzip -q -o xchtmlreport.zip")
          Actions.sh("rm xchtmlreport.zip")
          Actions.sh("mv release/xchtmlreport #{binary_path.shellescape}")
          Actions.sh("rm -rf release")
        end

        Actions.sh("#{binary_path.shellescape} -z -i -r #{lane_context[SharedValues::SCAN_GENERATED_XCRESULT_PATH].shellescape}")
        Actions.sh("mv index.html fastlane/test_output/test_report.html")
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