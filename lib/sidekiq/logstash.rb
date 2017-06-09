require 'sidekiq/logstash/configuration'
require 'sidekiq/logstash/version'
require 'sidekiq/middleware/server/logstah_logging'
require 'sidekiq/logging/logstash_formatter'
require 'sidekiq/logging/argument_filter'

module Sidekiq
  module Logstash
    def self.configuration
      @configuration ||= Configuration.new
    end

    def self.configure
      yield(configuration)
    end

    def self.setup(opts = {})
      # Calls Sidekiq.configure_server to inject logics
      Sidekiq.configure_server do |config|
        # Remove default Sidekiq error_handler that logs errors
        config.error_handlers.delete_if {|h| h.is_a?(Sidekiq::ExceptionHandler::Logger) }

        # Add logstash support
        config.server_middleware do |chain|
          chain.add Sidekiq::Middleware::Server::LogstashLogging
          chain.remove Sidekiq::Logging
        end

        # Set custom formatter for Sidekiq logger
        config.logger.formatter = Sidekiq::Logging::LogstashFormatter.new
      end
    end
  end
end
