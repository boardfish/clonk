# frozen_string_literal: true

require_relative 'client'

module Clonk
  class Connection
    attr_writer :realm

    def initialize(base_url:, realm_id:, username: nil, password: nil, client_id: nil, access_token: nil)
      @base_url = base_url
      @client_id = client_id
      if [username, password].all? &:nil?
        @access_token = access_token
      else
        initial_access_token(username: username, password: password, realm_id: realm_id, client_id: client_id)
      end
      @realm = create_instance_of('Realm', parsed_response(path: "/auth/realms/#{realm_id}"))
    end

    def clients
      objects(type: 'Client')
    end

    def roles(client:)
      objects(type: 'Role', root: url_for(client))
    end

    def groups(user: nil)
      return objects(type: 'Group') unless user

      objects(type: 'Group', path: "/users/#{user.id}/groups")
    end

    def subgroups(group)
      subgroups = config(group)['subGroups']
      return [] if subgroups.nil?

      subgroups.map { |group| create_instance_of('Group', group) }
    end

    def users
      objects(type: 'User')
    end

    def realms
      objects(type: 'Realm', path: '', root: realm_admin_root(nil))
    end

    def create_realm(**data)
      create_object(type: 'Realm', path: '', root: realm_admin_root(nil), data: { enabled: true, id: data['realm'] }.merge(data))
    end

    def create_user(**data)
      create_object(type: 'User', data: { enabled: true }.merge(data))
    end

    def create_client(**data)
      create_object(type: 'Client', data: { fullScopeAllowed: false }.merge(data))
    end


    ##
    # Creates a role within the given client.
    # it will be visible in tokens given by this client during authentication,
    # as it is already in scope.

    def create_role(client:, **data)
      create_object(type: 'Role', root: url_for(client), data: data)
    end

    def create_group(**data)
      return if data[:name].nil?

      create_object(type: 'Group', data: data)
    end

    def create_subgroup(group:, **data)
      create_object(type: 'Group', path: "/groups/#{group.id}/children", data: data)
    end

    def add_to_group(user:, group:)
      response(
        method: :put,
        path: "#{realm_admin_root}/users/#{user.id}/groups/#{group.id}",
        data: {
          userId: user.id,
          groupId: group.id,
          realm: @realm.name
        }
      )
    end

    def create_object(type:, path: "/#{type.downcase}s", root: realm_admin_root, data: {})
      creation_response = response(
        method: :post,
        path: root + path,
        data: data
      )

      create_instance_of(
        type,
        parsed_response(
          path: creation_response.headers[:location]
        )
      )
    end

    def objects(type:, path: "/#{type.downcase}s", root: realm_admin_root)
      parsed_response(path: root + path).map { |object_response| create_instance_of(type, object_response) }
    end

    def create_instance_of(class_name, response)
      Object.const_get('Clonk').const_get(class_name).new(response) || response
    end

    def delete(object)
      response(
        path: url_for(object),
        method: :delete
      )
    end

    def config(object)
      class_name = object.class.name.split('::').last.downcase + 's'
      class_name = 'roles-by-id' if class_name == 'roles'
      route = realm_admin_root + "/#{class_name}/#{object.id}"

      parsed_response(path: route)
    end

    def map_role(role:, target:)
      client_path = role.container_id == @realm ? 'realm' : "clients/#{role.container_id}"
      parsed_response(
        method: :post,
        data: [config(role)],
        path: "#{url_for(target)}/role-mappings/#{client_path}"
      )
    end

    def set_password_for(user:, password: nil, temporary: false)
      response(
        method: :put,
        data: {
          type: 'password',
          value: password,
          temporary: temporary
        },
        path: "#{url_for(user)}/reset-password"
      )
    end

    # Connection detail
    ####################

    def initial_access_token(username: @username, password: @password, client_id: @client_id, realm_id: @realm.name)
      data = {
        username: username,
        password: password,
        grant_type: 'password',
        client_id: client_id
      }
      @access_token = parsed_response(
        method: :post,
        path: "/auth/realms/#{realm_id}/protocol/openid-connect/token",
        connection_params: { json: false, raise_error: true },
        data: data
      )['access_token']
    end

    ##
    # Defines a Faraday::Connection object linked to the SSO instance.

    def connection(raise_error: true, json: true, token: @access_token)
      Faraday.new(url: @base_url) do |faraday|
        faraday.request(json ? :json : :url_encoded)
        faraday.use Faraday::Response::RaiseError if raise_error
        faraday.adapter Faraday.default_adapter
        faraday.headers['Authorization'] = "Bearer #{token}" unless token.nil?
      end
    end

    ##
    # Returns a Faraday::Response for an API call via the given method.
    # Always uses an admin token.

    def response(method: :get, path: '/', data: nil, connection_params: {})
      return unless %i[get post put delete].include?(method)

      connection(connection_params).public_send(method, path, data)
    end

    ##
    # Returns a parsed JSON response for an API call via the given method.
    # Useful in instances where only the data is necessary, and not
    # HTTP status confirmation that the desired effect was caused.
    # Always uses an admin token.

    def parsed_response(method: :get, path: '/', data: nil, connection_params: {})
      resp = response(method: method, path: path, data: data, connection_params: connection_params)

      JSON.parse(resp.body)
    rescue JSON::ParserError
      resp.body
    end

    ##
    # Returns the admin API root for the realm.

    def realm_admin_root(realm = @realm)
      "#{@base_url}/auth/admin/realms/#{realm&.name}"
    end

    def url_for(target)
      class_name = target.class.name.downcase
      "#{realm_admin_root}/#{target.class.name.split('::').last.downcase}s/#{target.id}"
    end
  end
end
