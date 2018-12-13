# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Clonk::Connection' do
  let(:client) { admin_client }
  let(:clients) { admin_client.clients }

  it 'requests to the right endpoint' do
    clients
    assert_requested :get, 'http://sso:8080/auth/admin/realms/test/clients'
  end

  it 'returns all clients' do
    expect(clients.count).to be >= 5
  end

  it 'returns an Array' do
    expect(clients).to be_an_instance_of(Array)
  end

  it 'returns an Array of Client' do
    expect(clients).to all(be_a(Clonk::Client))
  end

  it 'creates another client in SSO' do
    # skip 'pending addition of delete method'
    # clear_clients
    list_pre_addition = clients
    new_client = client.create_client(name: Faker::Overwatch.unique.hero)
    list_post_addition = admin_client.clients
    expect(list_post_addition.count - list_pre_addition.count).to eq(1)
  end

  def clear_clients
    default_clients = %w[account admin-cli broker realm-management security-admin-console]
    clients.reject { |client| default_clients.include?(client.name) }.map(&:delete)
  end
end
