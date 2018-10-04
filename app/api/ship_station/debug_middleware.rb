module ShipStation
  class DebugMiddleware <  Grape::Middleware::Base

    def initialize(app, options)
      super

      @logger = @options[:logger]
    end

    def call(env)
      headers = env.select {|k,v| k.start_with? 'HTTP_'}
                    .map {|pair| [pair[0].sub(/^HTTP_/, ''), pair[1]].join(": ")}
                    .sort

      request_params = env['rack.input'].read

      @logger.debug "Request: #{env["REQUEST_METHOD"]} #{env["PATH_INFO"]} (#{env["CONTENT_TYPE"]}) #{headers} #{request_params}"

      @app.call(env).tap do |response|
        status, headers, body = *response

        @logger.debug "Response: #{status}"
        @logger.debug "Headers: #{headers}"
        @logger.debug "Response:"

        body.each do |line|
          @logger.debug line
        end
      end
    end
  end
end
