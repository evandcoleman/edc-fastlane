module Fastlane
  module Actions
    class CodeCoverageAction < Action
      def self.run(params)
        Actions.sh("curl https://keybase.io/codecovsecurity/pgp_keys.asc | gpg --no-default-keyring --keyring trustedkeys.gpg --import")
        Actions.sh("curl -Os https://uploader.codecov.io/latest/macos/codecov")
        Actions.sh("curl -Os https://uploader.codecov.io/latest/macos/codecov.SHA256SUM")
        Actions.sh("curl -Os https://uploader.codecov.io/latest/macos/codecov.SHA256SUM.sig")
        Actions.sh("gpgv codecov.SHA256SUM.sig codecov.SHA256SUM")
        Actions.sh("shasum -a 256 -c codecov.SHA256SUM")

        Actions.sh("chmod +x codecov")
        Actions.sh("./codecov")
      end

      def self.description
        "Uploads a code coverage report to codecov.io"
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