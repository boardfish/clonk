# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Clonk::Group' do
  let(:client) { admin_client }
  let(:groups) { admin_client.groups }

  it 'requests to the right endpoint' do
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
    list_pre_addition = admin_client.groups
    admin_client.create_group(name: Faker::Overwatch.unique.hero)
    list_post_addition = admin_client.groups
    expect(list_post_addition.count - list_pre_addition.count).to eq(1)
  end

  it 'creates a subgroup in SSO' do
    new_group = admin_client.create_group(name: Faker::Overwatch.unique.hero)
    conf_pre_addition = admin_client.config(new_group)
    admin_client.create_subgroup(
      group: new_group, name: Faker::Overwatch.unique.hero
    )
    conf_post_addition = admin_client.config(new_group)
    expect(
      conf_post_addition['subGroups'].size - conf_pre_addition['subGroups'].size
    ).to eq(1)
  end
end
