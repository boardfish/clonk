require_relative 'spec_helper'

describe 'Clonk::Role' do
  it 'requests to the right endpoint' do
    client = Clonk::Client.all.first
    Clonk::Role.all(client: client)
    assert_requested :get, "http://sso:8080/auth/admin/realms/test/clients"
  end

  it 'returns an Array' do
    client = Clonk::Client.all.first
    expect(Clonk::Role.all(client: client)).to be_an_instance_of(Array)
  end

  it 'returns an Array of Role' do
    client = Clonk::Client.all.first
    expect(Clonk::Role.all(client: client)).to all(be_a(Clonk::Role))
  end

  it 'creates another role in SSO' do
    client = Clonk::Client.all.first
    list_pre_addition = Clonk::Role.all(client: client)
    client.create_role(name: Faker::Overwatch.hero)
    list_post_addition = Clonk::Role.all(client: client)
    expect(list_post_addition.count - list_pre_addition.count).to eq(1)
  end
end