# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'json'

# Keycloak/Red Hat SSO API wrapper
module Clonk
  class << self
    def logout_url(base_url:, realm_id:, redirect_uri:)
      "#{base_url}/auth/realms/#{realm_id}/protocol/openid-connect/logout?redirect_uri=#{CGI.escape(redirect_uri)}"
    end

    def login_url(base_url:, realm_id:, redirect_uri:, client_id:)
      "#{base_url}/auth/realms/#{realm_id}/protocol/openid-connect/auth?response_type=code&client_id=#{client_id}&redirect_uri=#{CGI.escape(redirect_uri)}"
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
