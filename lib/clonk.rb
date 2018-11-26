# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
# require 'dotenv/load'
require 'json'
# require 'pp'

BASE_URL = URI.encode(ENV.fetch('SSO_BASE_URL'))
USERNAME = ENV.fetch('SSO_USERNAME')
PASSWORD = ENV.fetch('SSO_PASSWORD')
REALM = ENV.fetch('SSO_REALM')

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

    def realm_admin_root(realm = REALM)
      "#{BASE_URL}/auth/admin/realms/#{realm}"
    end

    ##
    # Retrieves a token for the admin user.

    def admin_token
      data = {
        username: USERNAME,
        password: PASSWORD,
        grant_type: 'password',
        client_id: 'admin-cli'
      }

      JSON.parse(
        connection(json: false)
        .post('/auth/realms/master/protocol/openid-connect/token', data).body
      )['access_token']
    end

    ##
    # Returns a Faraday::Response for an API call via the given method.
    # Always uses an admin token.
    #--
    # FIXME: Rename protocol to method - more descriptive
    #++

    def response(method: :get, path: '/', data: nil, token: admin_token)
      return unless %i[get post put delete].include?(method)

      conn = connection(token: token).public_send(method, path, data)
    end

    ##
    # Returns a parsed JSON response for an API call via the given method.
    # Useful in instances where only the data is necessary, and not
    # HTTP status confirmation that the desired effect was caused.
    # Always uses an admin token.
    #--
    # FIXME: Rename protocol to method - more descriptive
    #++

    def parsed_response(method: :get, path: '/', data: nil, token: admin_token)
      resp = response(method: method, path: path, data: data, token: token)

      JSON.parse(resp.body)
    rescue JSON::ParserError
      resp.body
    end

    ##
    # Enables permissions for the given object.
    #--
    # TODO: Add this method to other models that need it, if any
    #++

    def set_permissions(object: nil, type: nil, enabled: true, realm: REALM)
      parsed_response(
        method: :put,
        path: "#{realm_admin_root(realm)}/#{type}s/#{object['id']}/management/permissions",
        data: { enabled: enabled },
        token: @token
      )
    end

    ##
    # Returns the data for the permission with the given ID.
    #--
    # TODO: Move this method into Permission
    #++

    def get_permission(id: nil, realm: REALM)
      parsed_response(
        token: @token,
        path: "#{client_url(client: @realm_management, realm: realm)}/authz/resource-server/permission/scope/#{id}"
      )
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
