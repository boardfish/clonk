# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Clonk::Realm' do
  let(:client) { admin_client }
  let(:realms) { admin_client.realms }

  it 'requests to the right endpoint' do
    realms
    assert_requested :get, 'http://sso:8080/auth/admin/realms/', times: 2 # was requested on admin client init
  end

  it 'returns an Array' do
    expect(realms).to be_an_instance_of(Array)
  end

  it 'returns an Array of Realm' do
    expect(realms).to all(be_a(Clonk::Realm))
  end

  # Flaky
  it 'creates another realm in SSO' do
    # skip 'FIXME: 400'
    list_pre_addition = realms
    client.create_realm(realm: Faker::Overwatch.hero)
    list_post_addition = admin_client.realms
    expect(list_post_addition.count - list_pre_addition.count).to eq(1)
  end
end
