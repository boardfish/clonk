require_relative 'spec_helper'

describe 'Clonk::User' do
  def create_user(username)
    response = Clonk.response(method: :post,
                  path: "#{Clonk.realm_admin_root('test')}/users",
                  data: { username: username, enabled: true }
                  )
    Clonk::User.new_from_id(response.headers[:location].split('/')[-1], 'test')
  end

  before(:all) do
    2.times { create_user(Faker::Overwatch.unique.hero) }
  end

  it 'sends a request to the users endpoint' do
    Clonk::User.all
    assert_requested :get, "http://sso:8080/auth/admin/realms/test/users"
  end

  it 'returns an Array' do
    expect(Clonk::User.all).to be_an_instance_of(Array)
  end

  it 'returns an Array of User' do
    expect(Clonk::User.all).to all(be_a(Clonk::User))
  end

  it 'sends a delete request to the right route in SSO' do
    deleted_user = Clonk::User.all.first
    deleted_user.delete
    assert_requested :get, "http://sso:8080/auth/admin/realms/test/users/#{deleted_user.id}"
  end

  it 'deletes the user from SSO' do
    users_pre_delete = Clonk::User.all
    deleted_user = users_pre_delete.first
    deleted_user.delete
    expect(Clonk::User.all).not_to include(deleted_user)
  end

  it 'finds only the user with the given ID' do
    19.times { create_user(Faker::Overwatch.unique.hero) }
    create_user('jeff')
    expect(Clonk::User.find_by(username: 'jeff')).to be_an_instance_of(Clonk::User)
  end
end