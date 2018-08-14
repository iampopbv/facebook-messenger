require 'httparty'

module Facebook
  module Messenger
    #
    # This module provides functionality to manage custom labels for broadcasts.
    # @see https://developers.facebook.com/docs/messenger-platform/send-messages/broadcast-messages/target-broadcasts
    #
    module Labels
      include HTTParty

      # The broadcast features require API v2.11 or above. We should probably
      # make this version available somewhere else as a global variable and
      # try to bump it to the latest version.
      base_uri 'https://graph.facebook.com/v2.11'

      format :json

      module_function

      #
      # Create a custom label.
      #
      # @raise [Facebook::Messenger::Labels::Error] if error is present
      #   in response.
      #
      # @param [String] name String with the name of the label to create.
      # @param [String] access_token Access token of facebook page.
      #
      # @return [String] The response body.
      #
      def create_label(name, access_token:)
        response = post '/me/custom_labels', body: {
          name: name
        }.to_json, query: { access_token: access_token }

        raise_errors(response)

        response.body
      end

      #
      # Delete a custom label.
      #
      # @raise [Facebook::Messenger::Labels::Error] if error is present
      #   in response.
      #
      # @param [String] label_id String with the custom label id.
      # @param [String] access_token Access token of facebook page.
      #
      # @return [String] If the label is successfully deleted, returns true.
      #
      def delete_label(label_id, access_token:)
        response = delete "/#{label_id}", query: { access_token: access_token }

        raise_errors(response)

        true
      end

      #
      # List all custom labels.
      #
      # @raise [Facebook::Messenger::Labels::Error] if error is present
      #   in response.
      #
      # @param [String] access_token Access token of facebook page.
      #
      # @return [String] If the label is successfully deleted, returns true.
      #
      def list_labels(access_token:)
        get_paged_data url: '/me/custom_labels?fields=name',
                       access_token: access_token
      end

      #
      # Subscribe a user to a label.
      #
      # @raise [Facebook::Messenger::Labels::Error] if error is present
      #   in response.
      #
      # @param [String] user_psid String with the user psid.
      # @param [String] label_id String with the custom label id.
      # @param [String] access_token Access token of facebook page.
      #
      # @return [Boolean] If the user is successfully tagged, returns true.
      #
      def subscribe_label(user_psid, label_id, access_token:)
        response = post "/#{label_id}/label", body: {
          user: user_psid
        }.to_json, query: { access_token: access_token }

        raise_errors(response)

        true
      end

      #
      # Unsubscribe a user from a label.
      #
      # @raise [Facebook::Messenger::Labels::Error] if error is present
      #   in response.
      #
      # @param [String] user_psid String with the user psid.
      # @param [String] label String with the custom label id.
      # @param [String] access_token Access token of facebook page.
      #
      # @return [Boolean] If the user is successfully untagged, returns true.
      #
      def unsubscribe_label(user_psid, label_id, access_token:)
        response = delete "/#{label_id}/label", query: {
          user: user_psid,
          access_token: access_token
        }

        raise_errors(response)

        true
      end

      #
      # List all labels of a user.
      #
      # @raise [Facebook::Messenger::Labels::Error] if error is present
      #   in response.
      #
      # @param [String] user_psid String with the user psid.
      # @param [String] access_token Access token of facebook page.
      #
      # @return [Boolean] If the user is successfully untagged, returns true.
      #
      def list_user_labels(user_psid, access_token:)
        get_paged_data url: "/#{user_psid}/custom_labels?fields=name",
                       access_token: access_token
      end

      #
      # Function raises error if response has error key.
      #
      # @raise [Facebook::Messenger::Labels::Error] if error is present
      #   in response.
      #
      # @param [Hash] response Response hash from facebook.
      #
      def raise_errors(response)
        raise Error, response['error'] if response.key? 'error'
      end

      #
      # Default HTTParty options.
      #
      # @return [Hash] Default HTTParty options.
      #
      def default_options
        super.merge(
          headers: {
            'Content-Type' => 'application/json'
          }
        )
      end

      #
      # Performs a GET request for a paged endpoint, following any pagination if
      # present, returning a list with all the results.
      #
      def get_paged_data(url:, access_token:, current_data: [])
        response = get url, query: { access_token: access_token }

        raise_errors(response)

        parsed_response = JSON.parse(response.body)

        current_data += parsed_response['data']

        next_page_url = parsed_response['paging']['next']
        if next_page_url.present?
          # Remove base uri from the returned url
          next_page_url.gsub!(base_uri, '')

          return get_paged_data url: next_page_url,
                                access_token: access_token,
                                current_data: current_data
        end

        current_data
      end

      #
      # Class Error provides errors related to custom labels.
      #
      class Error < Facebook::Messenger::FacebookError; end
    end
  end
end
