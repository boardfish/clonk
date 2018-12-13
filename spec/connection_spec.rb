# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Clonk::Connection' do
  let(:client) { admin_client }
  context 'users' do
    it 'sends a request to the users endpoint' do
      client.users
      assert_requested :get, 'http://sso:8080/auth/admin/realms/test/users'
    end

    it 'returns an Array' do
      expect(client.users).to be_an_instance_of(Array)
    end

    it 'returns an Array of User' do
      expect(client.users).to all(be_a(Clonk::User))
    end

    context 'when creating a user' do
      it 'creates a user in SSO' do
        initial_users = client.users
        client.create_user(username: 'foo')
        expect(client.users.count - initial_users.count).to eq(1)
      end

      it 'returns a User object' do
        expect(client.create_user(username: 'bar'))
          .to be_an_instance_of(Clonk::User)
      end
    end
  end

  context 'clients' do
    it 'sends a request to the clients endpoint' do
      client.clients
      assert_requested :get, 'http://sso:8080/auth/admin/realms/test/clients'
    end

    it 'returns an Array' do
      expect(client.clients).to be_an_instance_of(Array)
    end

    it 'returns an Array of Client' do
      expect(client.clients).to all(be_a(Clonk::Client))
    end

    context 'when creating a client' do
      it 'creates a client in SSO' do
        initial_clients = client.clients
        client.create_client(clientId: 'foo')
        expect(client.clients.count - initial_clients.count).to eq(1)
      end

      it 'returns a Client object' do
        expect(client.create_client(clientId: 'bar'))
          .to be_an_instance_of(Clonk::Client)
      end
    end
  end

  context 'groups' do
    it 'sends a request to the clients endpoint' do
      client.groups
      assert_requested :get, 'http://sso:8080/auth/admin/realms/test/groups'
    end

    it 'returns an Array' do
      expect(client.groups).to be_an_instance_of(Array)
    end

    it 'returns an Array of Group' do
      expect(client.groups).to all(be_a(Clonk::Group))
    end

    context 'when creating a group' do
      it 'creates a group in SSO' do
        initial_groups = client.groups
        client.create_group(name: 'foo')
        expect(client.groups.count - initial_groups.count).to eq(1)
      end

      it 'returns a Group object' do
        expect(client.create_group(name: 'bar'))
          .to be_an_instance_of(Clonk::Group)
      end
    end
  end
end
