# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
# require 'dotenv/load'
require 'json'
# require 'pp'

BASE_URL = ENV.fetch('SSO_BASE_URL')
USERNAME = ENV.fetch('SSO_USERNAME')
PASSWORD = ENV.fetch('SSO_PASSWORD')
REALM = ENV.fetch('SSO_REALM')

module Clonk
  class << self
    def connection(token: nil, raise_error: true, json: true)
      Faraday.new(url: BASE_URL) do |faraday|
        faraday.request(json ? :json : :url_encoded)
        faraday.use Faraday::Response::RaiseError if raise_error
        faraday.adapter Faraday.default_adapter
        faraday.headers['Authorization'] = "Bearer #{token}" if token
      end
    end

    def realm_admin_root(realm = REALM)
      "#{BASE_URL}/auth/admin/realms/#{realm}"
    end

    def client_url(client: nil, realm: REALM)
      "#{realm_admin_root(realm)}/clients/#{client['id']}"
    end

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

    def response(protocol: :get, path: '/', data: nil, token: admin_token)
      return unless %i[get post put delete].include?(protocol)

      conn = connection(token: token).public_send(protocol, path, data)
    end

    def parsed_response(protocol: :get, path: '/', data: nil, token: admin_token)
      resp = response(protocol: protocol, path: path, data: data, token: token)

      JSON.parse(resp.body)
    rescue JSON::ParserError
      resp.body
    end

    def create_realm(name: nil)
      parsed_response(
        protocol: :post,
        path: '/auth/admin/realms',
        data: { id: name, realm: name, enabled: true },
        token: @token
      )
    end

    # dag stands for Direct Access Grants
    def create_client(realm: REALM, id: nil, public_client: true, dag_enabled: true)
      # TODO: Client with a secret
      parsed_response(
        protocol: :post,
        path: "#{realm_admin_root(realm)}/clients",
        data: {
          clientId: id,
          publicClient: public_client,
          fullScopeAllowed: false,
          directAccessGrantsEnabled: dag_enabled
        }, token: @token
      )
    end

    def create_role(realm: REALM, name: nil, description: nil, scope_param_required: false, client: nil)
      parsed_response(protocol: :post,
                      path: "#{client_url(realm: realm, client: client)}/roles",
                      data: {
                        name: name,
                        description: description,
                        scopeParamRequired: scope_param_required
                      },
                      token: @token)
    end

    def add_user_to_group(group: nil, user: nil, realm: REALM)
      # put users/#{user['id']}/groups/#{group['id']}
      # data: gid, uid, realm
      parsed_response(
        protocol: :put,
        path: "#{user_url(user: user, realm: realm)}/groups/#{group['id']}",
        data: {
          groupId: group['id'],
          userId: user['id'],
          realm: realm
        },
        token: @token
      )
    end

    def set_permissions(object: nil, type: nil, enabled: true, realm: REALM)
      parsed_response(
        protocol: :put,
        path: "#{realm_admin_root(realm)}/#{type}s/#{object['id']}/management/permissions",
        data: { enabled: enabled },
        token: @token
      )
    end

    def roles(client: nil, target: nil, target_type: nil, realm: REALM)
      # need this to work with realms too
      case target
      when nil
        path = "#{realm_admin_root(realm)}/clients/#{client['id']}/roles"
      else
        path = "#{realm_admin_root(realm)}/#{target_type}s/#{target['id']}/role-mappings/clients/#{client['id']}/available"
      end
      parsed_response(
        protocol: :get,
        path: path,
        token: @token
      )
    end

    def get_role(client: nil, target: nil, target_type: nil, realm: REALM, name: nil)
      roles(client: client, target: target, target_type: target_type, realm: realm)
        .select { |role| role['name'] == name }&.first
    end

    def map_role(client: nil, role: nil, target: nil, target_type: :group, realm: REALM)
      client_path = client ? "clients/#{client['id']}" : 'realm'
      parsed_response(
        protocol: :post,
        token: @token,
        data: [role],
        path: "#{realm_admin_root(realm)}/#{target_type}s/#{target['id']}/role-mappings/#{client_path}"
      )
    end

    def map_scope(client: nil, role: nil, target: nil, realm: REALM)
      parsed_response(
        protocol: :post,
        token: @token,
        data: [role],
        path: "#{client_url(client: target, realm: realm)}/scope-mappings/clients/#{client['id']}"
      )
    end

    def get_permission(id: nil, realm: REALM)
      parsed_response(
        token: @token,
        path: "#{client_url(client: @realm_management, realm: realm)}/authz/resource-server/permission/scope/#{id}"
      )
    end

    # getPermissionScopes???
    # getPermissionResources???

    def policy_defaults
      {
        logic: 'POSITIVE',
        decisionStrategy: 'UNANIMOUS'
      }
    end

    def define_policy(type: :role, name: nil, roles: [])
      policy_defaults.merge(
        type: type,
        name: name,
        roles: roles.map { |role| role['id'] },
        description: description
      )
    end

    def create_policy(type: :role, name: nil, roles: [], realm: REALM)
      data = define_policy(type, name, roles)

      parsed_response(
        protocol: :post,
        token: @token,
        path: "#{client_url(client: @realm_management, realm: realm)}/authz/resource-server/policy/#{type}",
        data: data
      )
    end
  end
end

require 'clonk/group'
require 'clonk/user'
require 'clonk/client'
