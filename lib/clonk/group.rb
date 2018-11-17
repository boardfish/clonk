module Clonk
  module Group
    class << self
      def create(realm: Clonk::REALM, name: nil, token: Clonk.admin_token)
        Clonk.parsed_response(
          protocol: :post,
          path: "#{Clonk.realm_admin_root(realm)}/groups",
          data: { name: name }, 
          token: token
        )
      end

      def all(realm: REALM, flattened: false)
        response = parsed_response(
          protocol: :get, 
          path: "#{Clonk.realm_admin_root(realm)}/groups", 
        token: @token
        )
        response += response.map { |group| group['subGroups'] } if flattened
        response.flatten
      end

      def where(name: nil, realm: REALM)
        groups(flattened: true, realm: realm)
          .select { |group| group['name'] == name }
      end

      def find_by(name: nil, realm: REALM)
        where(name: name, realm: realm)&.first
      end
    end
  end
end