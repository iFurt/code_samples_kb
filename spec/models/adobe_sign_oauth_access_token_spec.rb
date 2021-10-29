require 'spec_helper'

describe AdobeSignOauthAccessToken do
  let(:access_token) { SecureRandom.hex }
  let(:refresh_token) { SecureRandom.hex }
  let(:expires_in) { '3600' }
  let(:response) do
    OpenStruct.new(
      'success?' => response_is_successful,
      'body' => { 'access_token' => access_token, 'refresh_token' => refresh_token, 'expires_in' => expires_in }.to_json
    )
  end

  before do
    allow(adobe_access_token).to receive(:form_urlencoded_request).and_return(response)
  end

  describe '#retreive_token!' do
    let(:adobe_access_token) { create(:adobe_sign_oauth_access_token, user: nil) }

    context 'when response is successful' do
      let(:response_is_successful) { true }

      it 'updates token and refresh token' do
        adobe_access_token.retreive_token!(nil)
        expect(adobe_access_token.token).to eq(access_token)
        expect(adobe_access_token.refresh_token).to eq(refresh_token)
      end
    end

    context 'when response is not successful' do
      let(:response_is_successful) { false }

      it 'raises error' do
        expect { adobe_access_token.retreive_token!(nil) }.to raise_error
      end
    end
  end

  describe '#refresh_token!' do
    let(:adobe_access_token) { create(:adobe_sign_oauth_access_token, user: nil, expires_at: 2.days.ago) }

    context 'when response is successful' do
      let(:response_is_successful) { true }

      it 'updates token and expiration time' do
        old_token = adobe_access_token.token
        old_refresh_token = adobe_access_token.refresh_token
        old_expires_at = adobe_access_token.expires_at
        adobe_access_token.refresh_token!
        expect(adobe_access_token.token).to eq(access_token)
        expect(adobe_access_token.refresh_token).to eq(old_refresh_token)
        expect(old_expires_at.past?).to be_truthy
        expect(adobe_access_token.expires_at.future?).to be_truthy
      end
    end

    context 'when response is not successful' do
      let(:response_is_successful) { false }

      it 'raises error' do
        expect { adobe_access_token.refresh_token! }.to raise_error
      end
    end
  end
end
