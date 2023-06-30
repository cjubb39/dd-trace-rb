# frozen_string_literal: true

module Datadog
  module Tracing
    module Contrib
      module Rack
        # Matches Rack-style headers with a matcher and sets matching headers into a span.
        module HeaderTagging
          def self.tag_request_headers(span, env, configuration)
            headers = Header::RequestHeaderCollection.new(env)

            # Use global DD_TRACE_HEADER_TAGS if integration-level configuration is not provided
            tags = if configuration.using_default?(:headers) && Datadog.configuration.tracing.header_tags
                     Datadog.configuration.tracing.header_tags.request_tags(headers)
                   else
                     whitelist = configuration[:headers][:request] || []
                     whitelist.each_with_object({}) do |header, result|
                       header_value = headers.get(header)
                       unless header_value.nil?
                         header_tag = Tracing::Metadata::Ext::HTTP::RequestHeaders.to_tag(header)
                         result[header_tag] = header_value
                       end
                     end
                   end

            span.set_tags(tags)
          end

          def self.tag_response_headers(span, headers, configuration)
            # Use global DD_TRACE_HEADER_TAGS if integration-level configuration is not provided
            tags = if configuration.using_default?(:headers) && Datadog.configuration.tracing.header_tags
                     Datadog.configuration.tracing.header_tags.response_tags(headers)
                   else
                     whitelist = configuration[:headers][:response] || []
                     whitelist.each_with_object({}) do |header, result|
                       if headers.key?(header)
                         result[Tracing::Metadata::Ext::HTTP::ResponseHeaders.to_tag(header)] = headers[header]
                       else
                         # Try a case-insensitive lookup
                         uppercased_header = header.to_s.upcase
                         matching_header = headers.keys.find { |h| h.upcase == uppercased_header }
                         if matching_header
                           result[Tracing::Metadata::Ext::HTTP::ResponseHeaders.to_tag(header)] = headers[matching_header]
                         end
                       end
                     end
                   end

            span.set_tags(tags)
          end
        end
      end
    end
  end
end
