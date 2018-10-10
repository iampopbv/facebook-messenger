require 'httparty'

module Facebook
  module Messenger
    #
    # Module MessageCreatives handles adding message creatives to your page
    #
    module MessageCreatives
      include HTTParty

      base_uri 'https://graph.facebook.com/v2.11/me'

      format :json

      module_function

      #
      # Function subscribe the facebook app to page.
      # @see https://developers.facebook.com/docs/messenger-platform/send-messages/broadcast-messages
      #
      # @raise [Facebook::Messenger::Subscriptions::Error] if there is any error
      #   in the response of subscribed_apps request.
      #
      # @param [String] access_token Access token of page to which bot has
      #   to subscribe.
      #
      # @return [String] MessageCreative ID
      #
      def create_message_creative(message, access_token:)
        response = post '/message_creatives',
                        body: JSON.dump(message),
                        format: :json,
                        query: {
                          access_token: access_token
                        }

        Facebook::Messenger::Bot::ErrorParser.raise_errors_from(response)

        response.body
      end

      #
      # If there is any error in response, raise error.
      #
      # @raise [Facebook::Messenger::Subscriptions::Error] If there is error
      #   in response.
      #
      # @param [Hash] response Response from facebook.
      #
      # @return Raise the error.
      #
      def raise_errors(response)
        raise Error, response['error'] if response.key? 'error'
      end

      #
      # Class Error provides errors related to message creatives.
      #
      class Error < Facebook::Messenger::FacebookError; end
    end
  end
end
