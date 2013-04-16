# Glass

This Gem is meant to help you quickly building application for Google Glass thanks to Ruby.

This is totally a beginning. Nothing is done.

This gem is using google/api-client

This gem is using Redis to store clients credentials

## Installation

Add this line to your application's Gemfile:

    gem 'glass'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install glass

## Usage

Setup Credential

```ruby
require 'glass'
Glass::Mirror.client_id = ENV['GLASS_CLIENT_ID']
Glass::Mirror.cient_secret = ENV['GLASS_CLIENT_SECRET']
Glass::Mirror.redirect_uri = ENV['GLASS_REDIRECT_URI']
Glass::Mirror.scopes += [# Add other requested scopes]
    # Default is 'https://www.googleapis.com/auth/drive.file',
    #            'https://www.googleapis.com/auth/userinfo.profile',

```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
