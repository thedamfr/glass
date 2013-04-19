require "glass/version"
require 'redis'
require 'redis-namespace'
require 'glass/config'
require 'google/api_client'
require 'json'

module Glass

  MIRROR= "mirror"

  INSERT= "INSERT"
  UPDATE= "UPDATE"
  DELETE= "DELETE"


  class Mirror


    class << self
      attr_accessor :scopes, :client_id, :redirect_uri, :client_secret
      @client_id
      @client_secret
      @redirect_uri
      @scopes = [
          'https://www.googleapis.com/auth/drive.file',
          'https://www.googleapis.com/auth/userinfo.profile',
      # Add other requested scopes.
      ]
    end


    @@config = Config.new()

    attr_accessor :client
    @client

    def self.hello_world
      "Hello World!"
    end

    # Returns the current Redis connection. If none has been created, will
    # create a new one.
    def self.redis
      @@config.redis
    end

    def self.redis= val
      @@config.redis = val
    end

    def self.redis_id
      @@config.redis_id
    end

    def self.no_redis= val
      @@config.no_redis=val
    end

    ##
    # Retrieved stored credentials for the provided user ID.
    #
    # @param [String] user_id
    #   User's ID.
    # @return [Signet::OAuth2::Client]
    #  Stored OAuth 2.0 credentials if found, nil otherwise.
    #
    def self.get_stored_credentials(user_id)
      unless @@config.no_redis
        hash = Redis.get(user_id)
        client = Google::APIClient.new
        client.authorization.dup
        client.update_token!(hash)
      end
    end

    ##
    # Store OAuth 2.0 credentials in the application's database.
    #
    # @param [String] user_id
    #   User's ID.
    # @param [Signet::OAuth2::Client] credentials
    #   OAuth 2.0 credentials to store.
    #
    def self.store_credentials(user_id, credentials)
      unless @@config.no_redis
        hash = Hash.new()
        hash[:access_token] = credentials.access_token
        hash[:refresh_token] = credentials.refresh_token
        hash[:expires_in] = credentials.expires_in
        hash[:issued_at] = credentials.issued_at

        Redis.set(user_id, hash)
      end
    end

    ##
    # Exchange an authorization code for OAuth 2.0 credentials.
    #
    # @param [String] auth_code
    #   Authorization code to exchange for OAuth 2.0 credentials.
    # @return [Signet::OAuth2::Client]
    #  OAuth 2.0 credentials.
    #
    def self.exchange_code(authorization_code)
      client = Google::APIClient.new
      client.authorization.client_id = client_id
      client.authorization.client_secret = client_secret
      client.authorization.code = authorization_code
      client.authorization.redirect_uri = redirect_uri

      begin
        client.authorization.fetch_access_token!
        return client.authorization
      rescue Signet::AuthorizationError
        raise CodeExchangeError.new(nil)
      end
    end

    ##
    # Send a request to the UserInfo API to retrieve the user's information.
    #
    # @param [Signet::OAuth2::Client] credentials
    #   OAuth 2.0 credentials to authorize the request.
    # @return [Google::APIClient::Schema::Oauth2::V2::Userinfo]
    #   User's information.
    #
    def self.get_user_info(credentials)
      client = Google::APIClient.new
      client.authorization = credentials
      oauth2 = client.discovered_api('oauth2', 'v2')
      result = client.execute!(:api_method => oauth2.userinfo.get)
      user_info = nil
      if result.status == 200
        user_info = result.data
      else
        puts "An error occurred: #{result.data['error']['message']}"
      end
      if user_info != nil && user_info.id != nil
        return user_info
      end
      raise NoUserIdError, "Unable to retrieve the user's Google ID."
    end

    ##
    # Retrieve authorization URL.
    #
    # @param [String] user_id
    #   User's Google ID.
    # @param [String] state
    #   State for the authorization URL.
    # @return [String]
    #  Authorization URL to redirect the user to.
    #
    def self.get_authorization_url(user_id, state)
      client = Google::APIClient.new
      client.authorization.client_id = client_id
      client.authorization.redirect_uri = redirect_uri
      client.authorization.scope = scopes

      return client.authorization.authorization_uri(
          :options => {
              :approval_prompt => :force,
              :access_type => :offline,
              :user_id => user_id,
              :state => state
          }).to_s
    end

    ##
    # Retrieve credentials using the provided authorization code.
    #
    #  This function exchanges the authorization code for an access token and queries
    #  the UserInfo API to retrieve the user's Google ID.
    #  If a refresh token has been retrieved along with an access token, it is stored
    #  in the application database using the user's Google ID as key.
    #  If no refresh token has been retrieved, the function checks in the application
    #  database for one and returns it if found or raises a NoRefreshTokenError
    #  with an authorization URL to redirect the user to.
    #
    # @param [String] auth_code
    #   Authorization code to use to retrieve an access token.
    # @param [String] state
    #   State to set to the authorization URL in case of error.
    # @return [Signet::OAuth2::Client]
    #  OAuth 2.0 credentials containing an access and refresh token.
    #
    def self.get_credentials(authorization_code, state="OAuth Failed")
      user_id = ''
      begin
        credentials = exchange_code(authorization_code)
        user_info = get_user_info(credentials)
        user_id = user_info.id
        if credentials.refresh_token != nil
          store_credentials(user_id, credentials)
          return credentials
        else
          credentials = get_stored_credentials(user_id)
          if credentials != nil && credentials.refresh_token != nil
            return credentials
          end
        end
      rescue CodeExchangeError => error
        print 'An error occurred during code exchange.'
        # Drive apps should try to retrieve the user and credentials for the current
        # session.
        # If none is available, redirect the user to the authorization URL.
        error.authorization_url = get_authorization_url(user_id, state)
        raise error
      rescue NoUserIdError
        print 'No user ID could be retrieved.'
      end

      authorization_url = get_authorization_url(user_id, state)
      raise NoRefreshTokenError.new(authorization_url)
    end


    ##
    # Build a Mirror client instance.
    #
    # @param [Signet::OAuth2::Client] credentials
    #   OAuth 2.0 credentials.
    # @return [Google::APIClient]
    #   Client instance
    def self.build_client(credentials)
      m = Mirror.new()
      m.client = Google::APIClient.new
      m.client.authorization = credentials
      m.client = m.client.discovered_api('mirror', 'v1')
      m
    end

    def self.build_with_code(authorization_code)
      return build_client(get_credentials(authorization_code))
    end

    def insert(item)
      item.insert(client)
    end

    def delete(item)
      item.delete(client)
    end

  end

##
# Error raised when an error occurred while retrieving credentials.
#
  class GetCredentialsError < StandardError
    ##
    # Initialize a NoRefreshTokenError instance.
    #
    # @param [String] authorize_url
    #   Authorization URL to redirect the user to in order to in order to request
    #   offline access.
    #
    def initialize(authorization_url)
      @authorization_url = authorization_url
    end

    def authorization_url=(authorization_url)
      @authorization_url = authorization_url
    end

    def authorization_url
      return @authorization_url
    end
  end

##
# Error raised when a code exchange has failed.
#
  class CodeExchangeError < GetCredentialsError
  end

##
# Error raised when no refresh token has been found.
#
  class NoRefreshTokenError < GetCredentialsError
  end

##
# Error raised when no user ID could be retrieved.
#
  class NoUserIdError < StandardError
  end


end

require 'glass/contacts/contact'
require 'glass/locations/location'
require 'glass/subscriptions/subscription'
require 'glass/timeline/timeline_item'