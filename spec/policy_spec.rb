# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Clonk::Connection' do
  let(:client) { admin_client }
  let(:policies) { admin_client.policies }

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
    policies
    assert_requested :get,
                     'http://sso:8080/auth/admin/realms/test/clients/' \
                     "#{realm_management.id}/authz/resource-server/policy"
  end

  it 'returns an Array' do
    expect(policies).to be_an_instance_of(Array)
  end

  it 'returns an Array of Policy' do
    expect(policies).to all(be_a(Clonk::Policy))
  end

  xit 'creates another policy in SSO' do
    list_pre_addition = admin_client.policies
    # admin_client.create_group(name: Faker::Overwatch.unique.hero)
    list_post_addition = admin_client.policies
    expect(list_post_addition.count - list_pre_addition.count).to eq(1)
  end
end
