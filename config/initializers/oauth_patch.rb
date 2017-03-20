require 'oauth2/client'

# Monkey patch of the OAuth2::Client from oauth2 gem
# This is because the response body defaults to HTML and is therefore unparseable by the gem
# and a limitation (bug ?) prevents any customisation of the 'Accept' content type in the request header
module OAuth2
  class Client

    # Initializes an AccessToken by making a request to the token endpoint
    #
    # @param [Hash] params a Hash of params for the token endpoint
    # @param [Hash] access token options, to pass to the AccessToken object
    # @param [Class] class of access token for easier subclassing OAuth2::AccessToken
    # @return [AccessToken] the initalized AccessToken
    def get_token(params, access_token_opts = {}, access_token_class = AccessToken)

      # Check that client site is the oauth provider and not the authorization site (which are different with Sitra)
      self.site = Rails.application.config.oauth_config[:auth_site] if site != Rails.application.config.oauth_config[:auth_site]

      opts = {:raise_errors => options[:raise_errors], :parse => params.delete(:parse)}
      if options[:token_method] == :post
        headers = params.delete(:headers)
        opts[:body] = params
        opts[:headers] =  {'Content-Type' => 'application/x-www-form-urlencoded'}
        opts[:headers].merge!(headers) if headers
      else
        opts[:headers] = params.delete(:headers)
        opts[:headers].merge!({'Accept' => 'application/json'})
        opts[:params] = params
      end

      response = request(options[:token_method], token_url, opts)
      error = Error.new(response)
      fail(error) if options[:raise_errors] && !(response.parsed.is_a?(Hash) && response.parsed['access_token'])
      access_token_class.from_hash(self, response.parsed.merge(access_token_opts))
    end

    # Activate for logging purposes
    # def request(verb, url, opts = {})
    #   Rails.logger.info "verb : #{verb}"
    #   Rails.logger.info "url : #{url}"
    #   Rails.logger.info "opts : #{opts}"
    # end

  end
end