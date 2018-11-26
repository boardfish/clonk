require_relative 'spec_helper'

describe 'Clonk::Client' do
  it 'requests to the right endpoint' do
    Clonk::Client.all
    assert_requested :get, "http://sso:8080/auth/admin/realms/test/clients"
  end

  it 'requests to the right endpoint' do
    clients = Clonk::Client.all
    expect(clients.count).to be >= 5
  end

  it 'returns an Array' do
    expect(Clonk::Client.all).to be_an_instance_of(Array)
  end

  it 'returns an Array of Client' do
    expect(Clonk::Client.all).to all(be_a(Clonk::Client))
  end

  it 'creates another client in SSO' do
    list_pre_addition = Clonk::Client.all
    new_client = Clonk::Client.create(name: Faker::Overwatch.unique.hero)
    list_post_addition = Clonk::Client.all
    expect(list_post_addition.count - list_pre_addition.count).to eq(1)
  end
end