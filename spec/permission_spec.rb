# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Clonk::Connection' do
  let(:client) { admin_client }
  let(:permissions) { admin_client.permissions }

  before(:all) do
    client = admin_client
    realm_management = client.clients.find do |client|
      client.name == 'realm-management'
    end
    prev_config = client.config(realm_management)
    client.response(
      method: :put,
      path: client.url_for(realm_management),
      data: prev_config.merge('authorizationServicesEnabled' => true)
    )
  end

  it 'requests to the right endpoint' do
    realm_management = client.clients.find do |client|
      client.name == 'realm-management'
    end
    permissions
    assert_requested :get,
                     'http://sso:8080/auth/admin/realms/test/clients/' \
                     "#{realm_management.id}/authz/resource-server/permission"
  end

  it 'returns an Array' do
    expect(permissions).to be_an_instance_of(Array)
  end

  it 'returns an Array of Policy' do
    expect(permissions).to all(be_a(Clonk::Permission))
  end

  xit 'creates another policy in SSO' do
    list_pre_addition = admin_client.permissions
    # admin_client.create_group(name: Faker::Overwatch.unique.hero)
    list_post_addition = admin_client.permissions
    expect(list_post_addition.count - list_pre_addition.count).to eq(1)
  end
end
