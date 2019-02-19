# frozen_string_literal: true

require_relative 'client'

module Clonk
  ##
  # Defines a connection to SSO.
  class Connection
    attr_writer :realm

    def initialize(base_url:, realm_id:, username:, password:, client_id: nil)
      @base_url = base_url
      @client_id = client_id
      initial_access_token(
        username: username, password: password, realm_id: realm_id,
        client_id: client_id
      )
      @realm = create_instance_of(
        'Realm', parsed_response(path: "/auth/realms/#{realm_id}")
      )
    end

    # Methods common to most/all kinds of objects in SSO
    ####################################################

    ##
    # Creates an object and returns an instance of it in SSO. Wrapped for each
    # type.
    def create_object(
      type:, path: "/#{type.downcase}s", root: realm_admin_root, data: {}
    )
      creation_response = response(
        method: :post, path: root + path, data: data
      )
      create_instance_of(
        type,
        parsed_response(
          path: creation_response.headers[:location]
        )
      )
    end

    ##
    # Returns all objects in the realm of that type. Wrapped for each type.
    def objects(type:, path: "/#{type.downcase}s", root: realm_admin_root)
      parsed_response(path: root + path).map do |object_response|
        create_instance_of(type, object_response)
      end
    end

    def create_instance_of(class_name, response)
      Object.const_get('Clonk').const_get(class_name).new(response) || response
    end

    def delete(object)
      response(path: url_for(object), method: :delete)
    end

    ##
    # Returns the config in SSO for an object.
    #--
    # FIXME: Does not work for policies or permissions
    #++
    def config(object)
      class_name = object.class.name.split('::').last.downcase + 's'
      class_name = 'roles-by-id' if class_name == 'roles'
      route = realm_admin_root + "/#{class_name}/#{object.id}"
      return parsed_response(path: url_fo(object)) if class_name == 'realm'
      parsed_response(path: route)
    end

    ##
    # Map a role to another object.
    # Common to groups and users
    def map_role(role:, target:)
      client_path = case role.container_id
                    when @realm
                      'realm'
                    else
                      "clients/#{role.container_id}"
                    end
      parsed_response(
        method: :post, data: [config(role)],
        path: "#{url_for(target)}/role-mappings/#{client_path}"
      )
    end

    # Connection detail
    ####################

    ##
    # Retrieves an initial access token for the user in the given realm.
    def initial_access_token(
      username: @username, password: @password, client_id: @client_id,
      realm_id: @realm.name
    )
      @access_token = parsed_response(
        method: :post,
        path: "/auth/realms/#{realm_id}/protocol/openid-connect/token",
        connection_params: { json: false, raise_error: true },
        data: {
          username: username, password: password, grant_type: 'password',
          client_id: client_id
        }
      )['access_token']
    end

    ##
    # Defines a Faraday::Connection object linked to the SSO instance.
    def connection(raise_error: false, json: true, token: @access_token)
      Faraday.new(url: @base_url) do |faraday|
        faraday.request(json ? :json : :url_encoded)
        faraday.use Faraday::Response::RaiseError if raise_error
        faraday.adapter Faraday.default_adapter
        faraday.headers['Authorization'] = "Bearer #{token}" unless token.nil?
      end
    end

    ##
    # Returns a Faraday::Response for an API call via the given method.
    def response(method: :get, path: '/', data: nil, connection_params: {})
      return unless %i[get post put delete].include?(method)

      connection(connection_params).public_send(method, path, data)
    end

    ##
    # Returns a parsed JSON response for an API call via the given method.
    # Useful in instances where only the data is necessary, and not
    # HTTP status confirmation that the desired effect was caused.
    def parsed_response(
      method: :get, path: '/', data: nil, connection_params: {}
    )
      resp = response(
        method: method, path: path, data: data,
        connection_params: connection_params
      )

      JSON.parse(resp.body)
    rescue JSON::ParserError
      resp.body
    end

    ##
    # Returns the admin API root for the realm.
    def realm_admin_root(realm = @realm)
      "#{@base_url}/auth/admin/realms/#{realm&.name}"
    end

    ##
    # Returns the URL for the given object.
    # Argument is necessary as permissions are sometimes treated as policies
    # within SSO for some reason, especially when fetching scopes, resources and
    # policies.
    # FIXME: Does not work with realms - realm_admin_root does, though.
    def url_for(target, prefix: 'permision/scope')
      class_name = target.class.name.split('::').last.downcase
      url_for_permission(target, prefix: prefix) if class_name == 'permission'
      return "#{realm_admin_root(target)}" if class_name == 'realm'
      "#{realm_admin_root}/#{class_name}s/#{target.id}"
    end

    def url_for_permission(permission, prefix: 'permission/scope')
      client_url = url_for(
        clients.find { |client| client.name == 'realm-management' }
      )
      "#{client_url}/authz/resource-server/#{prefix}/#{permission.id}"
    end

    def logout_url(realm_id: @realm.name, client_id: @client_id, redirect_uri:)
      "#{@base_url}/auth/realms/#{realm_id}/protocol/openid-connect/logout?redirect_uri=#{CGI.escape(redirect_uri)}"
    end

    def login_url(realm_id: @realm.name, redirect_uri:, client_id: @client_id)
      "#{@base_url}/auth/realms/#{realm_id}/protocol/openid-connect/auth?response_type=code&client_id=#{client_id}&redirect_uri=#{CGI.escape(redirect_uri)}"
    end
  end
end
