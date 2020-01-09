module Facebook
  module Messenger
    module Incoming
      # The Message reaction class represents an incoming Facebook Messenger message reaction
      # @see https://developers.facebook.com/docs/messenger-platform/reference/webhook-events/message-reactions
      class MessageReaction
        include Facebook::Messenger::Incoming::Common

        def payload
          @messaging['reaction']
        end

        def reaction
          @messaging['reaction']['reaction']
        end

        def emoji
          @messaging['reaction']['emoji']
        end

        def action
          @messaging['reaction']['action']
        end

        def mid
          @messaging['reaction']['mid']
        end
      end
    end
  end
end
