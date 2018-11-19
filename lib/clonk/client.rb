module Clonk
  class Client
    attr_accessor :id
    attr_reader :name

    def initialize(clients_response, realm)
      @id = clients_response['id']
      @name = clients_response['clientId']
      @realm = realm
    end

    def self.defaults
      {
        fullScopeAllowed: false
      }
    end
    # dag stands for Direct Access Grants
    def self.create(realm: REALM, name: nil, public_client: true, dag_enabled: true)
      # TODO: Client with a secret
      response = Clonk.response(
        protocol: :post,
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

    # Gets config inside SSO for client with ID in realm
    def self.get_config(id, realm = REALM)
      Clonk.parsed_response(
        path: "#{Clonk.realm_admin_root(realm)}/clients/#{id}"
      )
    end

    def config
      self.class.get_config(@id, @realm)
    end

    # Creates a new Client instance from a client that exists in SSO
    def self.new_from_id(id, realm = REALM)
      new(get_config(id, realm), realm)
    end

    def self.all(realm: REALM)
      Clonk.parsed_response(
        path: "#{Clonk.realm_admin_root(realm)}/clients"
      ).map { |client| new_from_id(client['id'], realm) }
    end

    def self.where(name: nil, realm: REALM)
      all(realm: realm).select { |client| client.name == name }
    end

    def self.find_by(name: nil, realm: REALM)
      where(name: name, realm: realm)&.first
    end

    def url
      "#{Clonk.realm_admin_root(@realm)}/clients/#{@id}"
    end

    def map_scope(client: nil, role: nil, realm: REALM)
      Clonk.parsed_response(
        protocol: :post,
        data: [role.config],
        path: "#{url}/scope-mappings/clients/#{client.id}"
      )
    end

    def create_role(realm: REALM, name: nil, description: nil, scope_param_required: false)
      # TODO: Create realm roles
      Clonk.parsed_response(protocol: :post,
                      path: "#{url}/roles",
                      data: {
                        name: name,
                        description: description,
                        scopeParamRequired: scope_param_required
                      })
    end

    def set_permissions(enabled: true)
      Clonk.parsed_response(
        protocol: :put,
        path: "#{url}/management/permissions",
        data: {
          enabled: enabled
        }
      )
    end

    def secret
      Clonk.parsed_response(
        path: "#{url}/client-secret"
      )['value']
    end
  end
end