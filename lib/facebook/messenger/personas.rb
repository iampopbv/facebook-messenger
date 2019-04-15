require 'httparty'

module Facebook
  module Messenger
    #
    # Module Personas handles create, retrieve and delete personas to/from Pages.
    #
    module Personas
      include HTTParty

      base_uri 'https://graph.facebook.com/v2.9'

      format :json

      module_function

      #
      # Function create a persona and associate it to a page.
      # @see https://developers.facebook.com/docs/messenger-platform/send-messages/personas/#create
      #
      # @raise [Facebook::Messenger::Personas::Error] iif error is present
      #   in response.
      #
      # @param [String] access_token Access token of page to which persona has
      #   to be associated.
      # @param [String] name Name of the persona that we want to associate.
      # @param [String] profile_picture_url Picture url that we want
      #   to associate to the Persona.
      #
      # @return [String] The response body containing a Persona ID that can
      #   be used to send future messages. This ID is private and unique
      #   to a Page.
      #
      def create_persona(name, profile_picture_url, access_token:)
        response = post '/me/personas', query: {
          access_token: access_token,
          name: name,
          profile_picture_url: profile_picture_url
        }

        raise_errors(response)

        response.body
      end

      #
      # Retrieve a persona with name and profile_picture_url.
      # @see https://developers.facebook.com/docs/messenger-platform/send-messages/personas/#get
      #
      # @raise [Facebook::Messenger::Personas::Error] if error is present
      #   in response.
      #
      # @param [Integer] persona_id ID of the persona to retrieve.
      # @param [String] access_token Access token of facebook page.
      #
      # @return [String] The response body containing a
      #   Persona name and picture url
      #
      def retrieve_persona(persona_id, access_token:)
        response = get "/#{persona_id}", query: {
          access_token: access_token
        }

        raise_errors(response)

        response.body
      end

      #
      # Function delete a persona from facebook page.
      # @see https://developers.facebook.com/docs/messenger-platform/send-messages/personas/#remove
      #
      # @raise [Facebook::Messenger::Personas::Error] if error is present
      #   in response.
      #
      # @param [Integer] persona_id ID of the persona to delete.
      # @param [String] access_token Access token of facebook page.
      #
      # @return [Boolean] TRUE
      #
      def delete_persona(persona_id, access_token:)
        response = delete "/#{persona_id}", query: {
          access_token: access_token
        }

        raise_errors(response)

        true
      end

      #
      # If there is any error in response, raise error.
      #
      # @raise [Facebook::Messenger::Personas::Error] If there is error
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
      # Class Error provides errors related to Personas.
      #
      class Error < Facebook::Messenger::FacebookError; end
    end
  end
end
