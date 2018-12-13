# frozen_string_literal: true

module Clonk
  ##
  # This class represents a client within SSO. A client allows a user to
  # authenticate against SSO with their credentials.
  class Client
    attr_accessor :id
    attr_reader :name

    def initialize(clients_response)
      @id = clients_response['id']
      @name = clients_response['clientId']
    end
  end
end
