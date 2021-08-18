require 'ddtrace/contrib/action_mailer/ext'
require 'ddtrace/contrib/action_mailer/event'

module Datadog
  module Contrib
    module ActionMailer
      module Events
        # Defines instrumentation for process.action_mailer event
        module Deliver
          include ActionMailer::Event

          EVENT_NAME = 'deliver.action_mailer'.freeze

          module_function

          def event_name
            self::EVENT_NAME
          end

          def span_name
            Ext::SPAN_DELIVER
          end

          def span_type
            # deliver.action_mailer sends emails
            Datadog::Ext::AppTypes::WORKER
          end

          def process(span, event, _id, payload)
            super

            span.span_type = span_type
            span.set_tag(Ext::TAG_MAILER, payload[:mailer])
            span.set_tag(Ext::TAG_MSG_ID, payload[:message_id])

            # Since email date can contain PII we disable by default
            # Some of these fields can be either strings or arrays, so we try to normalize
            # https://github.com/rails/rails/blob/18707ab17fa492eb25ad2e8f9818a320dc20b823/actionmailer/lib/action_mailer/base.rb#L742-L754
            if configuration[:email_data]
              span.set_tag(Ext::TAG_SUBJECT, payload[:subject].to_s) if payload[:subject]
              span.set_tag(Ext::TAG_TO, payload[:to].to_s) if payload[:to]
              span.set_tag(Ext::TAG_FROM, payload[:from].to_s) if payload[:from]
              span.set_tag(Ext::TAG_BCC, payload[:bcc].to_s) if payload[:bcc]
              span.set_tag(Ext::TAG_CC, payload[:cc].to_s) if payload[:cc]
              span.set_tag(Ext::TAG_DATE, payload[:date].to_s) if payload[:date]
              span.set_tag(Ext::TAG_PERFORM_DELIVERIES, payload[:perform_deliveries]) if payload[:perform_deliveries]
            end
          end
        end
      end
    end
  end
end
