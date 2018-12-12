# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Clonk::Role' do
  let(:client) { admin_client }
  let(:roles) { admin_client.roles(client: admin_client.clients.first) }

  it 'requests to the right endpoint' do
    roles
    assert_requested :get, 'http://sso:8080/auth/admin/realms/test/clients'
  end

  it 'returns an Array' do
    expect(roles).to be_an_instance_of(Array)
  end

  it 'returns an Array of Role' do
    expect(roles).to all(be_a(Clonk::Role))
  end

  # Flaky
  it 'creates another role in SSO' do
    list_pre_addition = roles
    client.create_role(client: admin_client.clients.first, name: Faker::Overwatch.hero)
    list_post_addition = admin_client.roles(client: admin_client.clients.first)
    expect(list_post_addition.count - list_pre_addition.count).to eq(1)
  end
end
