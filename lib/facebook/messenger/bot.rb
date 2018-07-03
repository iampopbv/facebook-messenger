require 'facebook/messenger/bot/error_parser'
require 'facebook/messenger/bot/exceptions'
require 'facebook/messenger/bot/messaging_type'

module Facebook
  module Messenger
    #
    # Module Bot provides functionality to sends and receives messages.
    #
    module Bot
      include HTTParty
      read_timeout 1800

      # Define base_uri for HTTParty.
      base_uri 'https://graph.facebook.com/v2.9/me'

      #
      # @return [Array] Array containing the supported webhook events.
      EVENTS = %i[
        message
        delivery
        postback
        optin
        read
        account_linking
        referral
        message_echo
        payment
        policy_enforcement
      ].freeze

      class << self
        # Deliver a message with the given payload.
        # @see https://developers.facebook.com/docs/messenger-platform/send-api-reference#request
        #
        # @raise [Facebook::Messenger::Bot::SendError] if there is any error
        #   in response while sending message.
        #
        # @param [Hash] message A Hash describing the recipient and the message.
        # @param [String] access_token Access token.
        #
        # Returns a String describing the message ID if the message was sent,
        # or raises an exception if it was not.
        def deliver(message, access_token:)
          response = post '/messages',
                          body: JSON.dump(message),
                          format: :json,
                          query: {
                            access_token: access_token
                          }

          Facebook::Messenger::Bot::ErrorParser.raise_errors_from(response)

          response.body
        end

        # Upload a file for later reuse using the Attachment Upload API.
        #
        # message - A Hash containing the file url*.
        # * https://developers.facebook.com/docs/messenger-platform/send-api-reference/attachment-upload#request
        #
        # Returns the response containing the attachment id if the upload was
        # successful, or raises an exception if it was not.
        def upload(message, access_token:)
          response = post '/message_attachments',
                          body: JSON.dump(message),
                          format: :json,
                          query: {
                            access_token: access_token
                          }

          Facebook::Messenger::Bot::ErrorParser.raise_errors_from(response)

          response.body
        end

        # Register a hook for the given event.
        #
        # @raise [ArgumentError] if received event is not registered.
        #
        # @param [String] event A String describing a Messenger event.
        # @param [Block] block A code block to run upon the event.
        #
        # @return Save event and its block in hooks.
        def on(event, &block)
          unless EVENTS.include? event
            raise ArgumentError,
                  "#{event} is not a valid event; " \
                  "available events are #{EVENTS.join(',')}"
          end

          hooks[event] = block
        end

        # Receive a given message from Messenger.
        #
        # @see https://developers.facebook.com/docs/messenger-platform/webhook-reference
        #
        # @param [Hash] payload A Hash describing the message.
        #
        # @return pass event and object of callback class to trigger function.
        #
        def receive(payload)
          callback = Facebook::Messenger::Incoming.parse(payload)
          event = Facebook::Messenger::Incoming::EVENTS.invert[callback.class]
          trigger(event.to_sym, callback)
        end

        # Trigger the hook for the given event.
        # Fetch callback for event from hooks and call it.
        #
        # @raise [KeyError] if hook is not registered for event
        #
        # @param [String] event A String describing a Messenger event.
        # @param [Object] args Arguments to pass to the hook.
        def trigger(event, *args)
          hooks.fetch(event).call(*args)
        rescue KeyError
          warn "Ignoring #{event} (no hook registered)"
        end

        #
        # Return a Hash of hooks.
        #
        # @return [Hash] Hash of hooks.
        #
        def hooks
          @hooks ||= {}
        end

        #
        # Deregister all hooks.
        #
        # @return [Hash] Assign empty hash to hooks and return it.
        #
        def unhook
          @hooks = {}
        end

        #
        # Default HTTParty options.
        #
        # @return [Hash] Default HTTParty options.
        #
        def default_options
          super.merge(
            read_timeout: 300,
            headers: {
              'Content-Type' => 'application/json'
            }
          )
        end
      end
    end
  end
end
