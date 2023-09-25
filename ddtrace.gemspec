# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ddtrace/version'

Gem::Specification.new do |spec|
  spec.name                  = 'ddtrace'
  spec.version               = DDTrace::VERSION::STRING
  spec.required_ruby_version = [">= #{DDTrace::VERSION::MINIMUM_RUBY_VERSION}",
                                "< #{DDTrace::VERSION::MAXIMUM_RUBY_VERSION}"]
  spec.required_rubygems_version = '>= 2.0.0'
  spec.authors               = ['Datadog, Inc.']
  spec.email                 = ['dev@datadoghq.com']

  spec.summary     = 'Datadog tracing code for your Ruby applications'
  spec.description = <<-DESC.gsub(/^\s+/, '')
    ddtrace is Datadog's tracing client for Ruby. It is used to trace requests
    as they flow across web servers, databases and microservices so that developers
    have great visiblity into bottlenecks and troublesome requests.
  DESC

  spec.homepage = 'https://github.com/DataDog/dd-trace-rb'
  spec.license  = 'BSD-3-Clause'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
    spec.metadata['changelog_uri'] = 'https://github.com/DataDog/dd-trace-rb/blob/master/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files =
    Dir[*%w[
      CHANGELOG.md
      LICENSE*
      NOTICE
      README.md
      bin/**/*
      ext/**/*
      lib/**/*
    ]]
      .select { |fn| File.file?(fn) } # We don't want directories, only files
      .reject { |fn| fn.end_with?('.so', '.bundle') } # Exclude local profiler binary artifacts
      .reject { |fn| fn.end_with?('skipped_reason.txt') } # Generated by profiler; should never be distributed

  spec.executables   = ['ddtracerb']
  spec.require_paths = ['lib']

  # Used to serialize traces to send them to the Datadog Agent.
  #
  # msgpack 1.4 fails for Ruby 2.1 (see https://github.com/msgpack/msgpack-ruby/issues/205)
  # so a restriction needs to be manually added for the `Gemfile`.
  #
  # We can't add a restriction here, since there's no way to add it only for older
  # rubies, see #1739 and #1336 for an extended discussion about this
  spec.add_dependency 'msgpack'

  # Used by the profiler native extension to support Ruby < 2.6 and > 3.2
  #
  # We decided to pin it at the latest available version and will manually bump the dependency as needed.
  spec.add_dependency 'debase-ruby_core_source', '= 3.2.1'

  # Used by appsec
  spec.add_dependency 'libddwaf', '~> 1.14.0.0.0'

  # Used by profiling (and possibly others in the future)
  # When updating the version here, please also update the version in `native_extension_helpers.rb` (and yes we have a test for it)
  spec.add_dependency 'libdatadog', '~> 4.0.0.1.0'

  # used for CI visibility product until the next major version
  spec.add_dependency 'datadog-ci', '~> 0.1.0'

  spec.extensions = ['ext/ddtrace_profiling_native_extension/extconf.rb', 'ext/ddtrace_profiling_loader/extconf.rb']
end
