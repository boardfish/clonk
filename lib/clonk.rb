# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
# require 'dotenv/load'
require 'json'
# require 'pp'

BASE_URL = CGI.escape(ENV.fetch('SSO_BASE_URL'))
USERNAME = ENV.fetch('SSO_USERNAME')
PASSWORD = ENV.fetch('SSO_PASSWORD')
REALM = ENV.fetch('SSO_REALM')

# Keycloak/Red Hat SSO API wrapper
module Clonk
  class << self
    ##
    # Defines a Faraday::Connection object linked to the SSO instance.

    def connection(token: nil, raise_error: true, json: true)
      Faraday.new(url: BASE_URL) do |faraday|
        faraday.request(json ? :json : :url_encoded)
        faraday.use Faraday::Response::RaiseError if raise_error
        faraday.adapter Faraday.default_adapter
        faraday.headers['Authorization'] = "Bearer #{token}" if token
      end
    end

    ##
    # Returns the admin API root for the realm.

    def realm_admin_root(realm)
      "/auth/admin/realms/#{realm}"
    end
  end
end

require 'clonk/group'
require 'clonk/user'
require 'clonk/client'
require 'clonk/policy'
require 'clonk/role'
require 'clonk/realm'
require 'clonk/permission'
require 'clonk/connection'
