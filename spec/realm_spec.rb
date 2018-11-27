require_relative 'spec_helper'

describe 'Clonk::Realm' do
  it 'requests to the right endpoint' do
    Clonk::Realm.all
    assert_requested :get, "http://sso:8080/auth/admin/realms"
  end

  it 'returns an Array' do
    expect(Clonk::Realm.all).to be_an_instance_of(Array)
  end

  it 'returns an Array of Realm' do
    expect(Clonk::Realm.all).to all(be_a(Clonk::Realm))
  end

  # Flaky
  it 'creates another realm in SSO' do
    list_pre_addition = Clonk::Realm.all
    Clonk::Realm.create(name: Faker::Overwatch.hero)
    list_post_addition = Clonk::Realm.all
    expect(list_post_addition.count - list_pre_addition.count).to eq(1)
  end
end