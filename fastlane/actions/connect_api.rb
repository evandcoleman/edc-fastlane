module Fastlane
  module Actions
    class ConnectApiAction < Action
      def self.run(params)
        require 'spaceship'
        http_method = params[:http_method]
        path = params[:path]
        params = params[:params]

        client = Spaceship::ConnectAPI.client.tunes_request_client
        response = client.send(http_method.downcase.to_sym, path, params)

        response.body
      end

      def self.description
        'Allows generic calls to the App Store Connect API'
      end

      def self.authors
        ['evandcoleman']
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :http_method,
                                       description: 'The HTTP method to use for the API call',
                                       is_string: true,
                                       default_value: 'GET'),
          FastlaneCore::ConfigItem.new(key: :path,
                                       description: 'The API endpoint path to call',
                                       is_string: true,
                                       verify_block: proc do |value|
                                         UI.user_error!('Invalid API endpoint path') unless value.start_with?('/')
                                       end),
          FastlaneCore::ConfigItem.new(key: :params,
                                       description: 'A hash of parameters to include in the API call',
                                       is_string: false,
                                       default_value: {})
        ]
      end

      def self.is_supported?(_platform)
        true
      end
    end
  end
end
