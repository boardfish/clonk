# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Clonk::Group' do
  it 'requests to the right endpoint' do
    Clonk::Group.all
    assert_requested :get, 'http://sso:8080/auth/admin/realms/test/groups'
  end

  it 'returns an Array' do
    expect(Clonk::Group.all).to be_an_instance_of(Array)
  end

  it 'returns an Array of Group' do
    expect(Clonk::Group.all).to all(be_a(Clonk::Group))
  end

  it 'creates another group in SSO' do
    Clonk::Group.all.each(&:delete)
    list_pre_addition = Clonk::Group.all
    new_group = Clonk::Group.create(name: Faker::Overwatch.unique.hero)
    list_post_addition = Clonk::Group.all
    expect(list_post_addition.count - list_pre_addition.count).to eq(1)
  end

  it 'creates a subgroup in SSO' do
    Clonk::Group.all.each(&:delete)
    new_group = Clonk::Group.create(name: Faker::Overwatch.unique.hero)
    config_pre_addition = new_group.config
    new_group.create_subgroup(name: Faker::Overwatch.unique.hero)
    config_post_addition = new_group.config
    expect(config_post_addition['subGroups'].count - config_pre_addition['subGroups'].count).to eq(1)
  end
end
