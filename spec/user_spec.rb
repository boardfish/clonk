# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Clonk::User' do
  let(:client) { admin_client }
  let(:users) { admin_client.users }

  before(:all) do
    2.times { admin_client.create_user(username: Faker::Overwatch.unique.hero) }
  end

  it 'sends a request to the users endpoint' do
    skip 'pending setup of client to point at test realm'
    users
    assert_requested :get, 'http://sso:8080/auth/admin/realms/test/users'
  end

  it 'returns an Array' do
    expect(users).to be_an_instance_of(Array)
  end

  it 'returns an Array of User' do
    expect(users).to all(be_a(Clonk::User))
  end

  it 'sends a delete request to the right route in SSO' do
    skip 'pending addition of delete method'
    deleted_user = users.first
    deleted_user.delete
    assert_requested :get, "http://sso:8080/auth/admin/realms/test/users/#{deleted_user.id}"
  end

  it 'deletes the user from SSO' do
    skip 'pending addition of delete method'
    users_pre_delete = users
    deleted_user = users_pre_delete.first
    deleted_user.delete
    expect(admin_client.users).not_to include(deleted_user)
  end

  it 'finds only the user with the given ID' do
    skip 'pending addition of delete method'
    skip 'pending addition of find_by'
    users.map(&:delete)
    19.times { admin_client.create_user(username: Faker::Overwatch.unique.hero) }
    create_user('jeff')
    expect(Clonk::User.find_by(username: 'jeff')).to be_an_instance_of(Clonk::User)
  end
end
