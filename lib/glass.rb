require "glass/version"

module Glass

  class Mirror
    attr_accessor :scopes, :client_id, :redirect_uri, :cient_secret
    @@client_id
    @@cient_secret
    @@redirect_uri
    @@scopes  = [
        'https://www.googleapis.com/auth/drive.file',
        'https://www.googleapis.com/auth/userinfo.profile',
    # Add other requested scopes.
    ]

  end

end
