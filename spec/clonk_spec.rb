# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Clonk' do
  let(:options) { {
    base_url: 'http://localhost:11037',
    realm_id: 'test',
    redirect_uri: 'http://localhost:2000',
    client_id: 'admin-cli'
  } }
  it 'returns a correct logout URI' do
    expect(Clonk.logout_url(options.except :client_id))
      .to eq('http://localhost:11037/auth/realms/test/protocol/openid-connect/logout?redirect_uri=http%3A%2F%2Flocalhost%3A2000')
  end

  it 'returns a correct login URI' do
    expect(Clonk.login_url(options))
      .to eq('http://localhost:11037/auth/realms/test/protocol/openid-connect/auth?response_type=code&client_id=admin-cli&redirect_uri=http%3A%2F%2Flocalhost%3A2000')
  end
end