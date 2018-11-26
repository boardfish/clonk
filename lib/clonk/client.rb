module Clonk

  ##
  # This class represents a client within SSO. A client allows a user to authenticate against SSO with their credentials.

  class Client
    attr_accessor :id
    attr_reader :name

    def initialize(clients_response, realm)
      @id = clients_response['id']
      @name = clients_response['clientId']
      @realm = realm
    end

    ##
    # Returns the defaults for some fields. The rest should be defined on a relevant call.

    def self.defaults
      {
        fullScopeAllowed: false
      }
    end

    ##
    # Creates a client within SSO and returns the created client as a Client.
    # Note: 'dag' stands for Direct Access Grants

    def self.create(realm: REALM, name: nil, public_client: true, dag_enabled: true)
      # TODO: Client with a secret
      response = Clonk.response(
        method: :post,
        path: "#{Clonk.realm_admin_root(realm)}/clients",
        data: defaults.merge(
          clientId: name,
          publicClient: public_client,
          directAccessGrantsEnabled: dag_enabled
        )
      )
      new_client_id = response.headers[:location].split('/')[-1]
      new_from_id(new_client_id, realm)
    end

    ##
    # Gets the config inside SSO for a particular client.
    # This allows for access to many attributes that Clonk might not directly
    # handle yet.
    # You may be able to extend Clonk's functionality by using Clonk.response
    # or Clonk.parsed_response with routes in the SSO API alongside this data.

    def self.get_config(id, realm = REALM)
      Clonk.parsed_response(
        path: "#{Clonk.realm_admin_root(realm)}/clients/#{id}"
      )
    end

    ##
    # Gets the config inside SSO for this client.

    def config
      self.class.get_config(@id, @realm)
    end

    ##
    # Creates a new Client instance from a client that exists in SSO

    def self.new_from_id(id, realm = REALM)
      new(get_config(id, realm), realm)
    end

    ##
    # Returns an array of the clients that exist in the given realm.

    def self.all(realm: REALM)
      Clonk.parsed_response(
        path: "#{Clonk.realm_admin_root(realm)}/clients"
      ).map { |client| new_from_id(client['id'], realm) }
    end

    ##
    # Searches for clients with the given name in the given realm.

    def self.where(name: nil, realm: REALM)
      all(realm: realm).select { |client| client.name == name }
    end

    ##
    # Searches for exactly one client with the given name in the given realm.

    def self.find_by(name: nil, realm: REALM)
      where(name: name, realm: realm)&.first
    end

    ##
    # Returns the URL that can be used to fetch this client's data from the API.

    def url
      "#{Clonk.realm_admin_root(@realm)}/clients/#{@id}"
    end

    ##
    # Maps the given role into the scope of the client. If a user has that role,
    # it will be visible in tokens given by this client during authentication.

    def map_scope(client: nil, role: nil, realm: REALM)
      Clonk.parsed_response(
        method: :post,
        data: [role.config],
        path: "#{url}/scope-mappings/clients/#{client.id}"
      )
    end

    ##
    # Creates a role within this client.
    # it will be visible in tokens given by this client during authentication, 
    # as it is already in scope.

    def create_role(realm: REALM, name: nil, description: nil, scope_param_required: false)
      # TODO: Create realm roles
      response = Clonk.response(method: :post,
                      path: "#{url}/roles",
                      data: {
                        name: name,
                        description: description,
                        scopeParamRequired: scope_param_required
                      })
      Role.find_by(name: name, client: self)
    end

    ##
    # Lists the client's permission IDs, if permissions are enabled.
    # These will be returned as either a boolean (false) if disabled,
    # or a hash of permission types and IDs.

    def permissions
      Clonk.parsed_response(
        path: "#{url}/management/permissions"
      )['scopePermissions'] || false
    end

    ##
    # Enables or disables permissions for a client

    def set_permissions(enabled: true)
      Clonk.parsed_response(
        method: :put,
        path: "#{url}/management/permissions",
        data: {
          enabled: enabled
        }
      )
    end

    ##
    # Returns the client's secret

    def secret
      Clonk.parsed_response(
        path: "#{url}/client-secret"
      )['value']
    end
  end
end