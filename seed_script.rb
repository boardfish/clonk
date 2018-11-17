# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'
require 'dotenv/load'
require 'json'
require 'pp'

BASE_URL = ENV.fetch('SSO_BASE_URL')
USERNAME = ENV.fetch('SSO_USERNAME')
PASSWORD = ENV.fetch('SSO_PASSWORD')
REALM = ENV.fetch('SSO_REALM')

def connection(token: nil, raise_error: true, json: true)
  Faraday.new(url: BASE_URL) do |faraday|
    faraday.request(json ? :json : :url_encoded)
    faraday.use Faraday::Response::RaiseError if raise_error
    faraday.adapter Faraday.default_adapter
    faraday.headers['Authorization'] = "Bearer #{token}" if token
  end
end

def realm_admin_root(realm: REALM)
  "/auth/admin/realms/#{realm}"
end

def client_url(client: nil, realm: REALM)
  "#{realm_admin_root(realm)}/clients/#{client['id']}"
end

def group_url(group: nil, realm: REALM)
  "#{realm_admin_root(realm)}/groups/#{group['id']}"
end

def user_url(user: nil, realm: REALM)
  "#{realm_admin_root(realm)}/users/#{user['id']}"
end

data = {
  username: USERNAME,
  password: PASSWORD,
  grant_type: 'password',
  client_id: 'admin-cli'
}

@token = JSON.parse(
  connection(json: false)
  .post('/auth/realms/master/protocol/openid-connect/token', data).body
)['access_token']

def parsed_response(protocol: :get, path: '/', data: nil, token: nil)
  return unless %i[get post put delete].include?(protocol)

  response = connection(token: token).public_send(protocol, path, data)
  JSON.parse(response.body)
rescue JSON::ParserError
  response.body
end

def create_realm(name: nil)
  parsed_response(
    protocol: :post,
    path: '/auth/admin/realms',
    data: { id: name, realm: name, enabled: true },
    token: @token
  )
end

def create_user(realm: REALM, username: nil, enabled: true)
  parsed_response(protocol: :post,
                  path: "#{realm_admin_root(realm)}/users",
                  data: { username: username, enabled: enabled },
                  token: @token)
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

def clients(realm: REALM)
  parsed_response(
    protocol: :get,
    path: "#{realm_admin_root(realm)}/clients",
    token: @token
    )
end

def get_client(name: nil, realm: REALM)
  clients(realm: realm).select { |client| client['clientId'] == name }[0]
end

def groups(realm: REALM, flattened: false)
  response = parsed_response(
    protocol: :get, 
    path: "#{realm_admin_root(realm)}/groups", 
  token: @token
  )
  response += response.map { |group| group['subGroups'] } if flattened
  response.flatten
end

# Runs on safe assumption that you won't name a subgroup like a group
def get_group(name: nil, realm: REALM)
  groups(flattened: true, realm: realm)
    .select { |group| group['name'] == name }&.first
end

def create_group(realm: REALM, name: nil)
  parsed_response(
    protocol: :post,
    path: "#{realm_admin_root(realm)}/groups",
    data: { name: name }, token: @token
  )
end

def users(realm: REALM)
  parsed_response(
    path: "#{realm_admin_root(realm)}/users",
    token: @token
  )
end

def get_user(username: nil, realm: REALM)
  users(realm: realm).select { |user| user['username'] == username }.first
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