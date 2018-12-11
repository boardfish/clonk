# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Clonk::Group' do
  let(:client) { admin_client }
  let(:groups) { admin_client.groups }

  it 'requests to the right endpoint' do
    skip 'pending change to helper to point at test realm'
    groups
    assert_requested :get, 'http://sso:8080/auth/admin/realms/test/groups'
  end

  it 'returns an Array' do
    expect(groups).to be_an_instance_of(Array)
  end

  it 'returns an Array of Group' do
    expect(groups).to all(be_a(Clonk::Group))
  end

  it 'creates another group in SSO' do
    skip 'pending addition of delete method'
    groups.each(&:delete)
    list_pre_addition = admin_client.groups
    new_group = admin_client.create_group(name: Faker::Overwatch.unique.hero)
    list_post_addition = admin_client.groups
    expect(list_post_addition.count - list_pre_addition.count).to eq(1)
  end

  it 'creates a subgroup in SSO' do
    skip 'pending addition of delete method'
    groups.each(&:delete)
    new_group = admin_client.create_group(name: Faker::Overwatch.unique.hero)
    config_pre_addition = new_group.config
    admin_client.create_subgroup(group: new_group, name: Faker::Overwatch.unique.hero)
    config_post_addition = new_group.config
    expect(config_post_addition['subGroups'].count - config_pre_addition['subGroups'].count).to eq(1)
  end
end
