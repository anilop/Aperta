# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

describe TahiDevise::OmniauthCallbacksController do

  before(:each) do
    # tell devise what route we are using
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "#orcid" do

    context "a new orcid user attempts to log into plos" do
      before(:each) do
        allow_any_instance_of(TahiDevise::OmniauthCallbacksController).to receive(:auth).and_return({uid: "uid", provider: "orcid"})
      end

      it "will redirect to registration page" do
        get :orcid
        expect(response).to redirect_to new_user_registration_path
      end
    end

    context "an existing orcid user logs into plos" do

      let(:user) { FactoryGirl.create(:user, :orcid, password: "abcd1234", password_confirmation: "abcd1234") }
      let(:credential) { user.credentials.first }

      before(:each) do
        allow_any_instance_of(TahiDevise::OmniauthCallbacksController).to receive(:auth).and_return({uid: credential.uid, provider: credential.provider})
      end

      it "will redirect to dashboard" do
        get :orcid
        expect(response).to redirect_to root_path
      end
    end

  end

  describe "#cas" do

    let(:cas_id) { FactoryGirl.attributes_for(:cas_credential).fetch(:uid) }
    let(:auth_hash) { { provider: :cas, uid: cas_id, extra: { firstName: "Bill", lastName: "Jones", emailAddress: "email@example.com", displayName: "bjones", nedId: 12345 } } }

    context "a new cas user attempts to log into plos", vcr: { cassette_name: 'ned' } do

      before(:each) do
        allow_any_instance_of(TahiDevise::OmniauthCallbacksController).to receive(:auth).and_return(auth_hash)
        expect_any_instance_of(User).to receive(:password_required?).at_least(:once).and_return(true)
      end

      it "will autogenerate a password" do
        get :cas
        expect(User.last.reload.encrypted_password).to_not be_blank
      end

      it "will redirect to the dashboard" do
        get :cas
        expect(response).to redirect_to root_path
      end
    end

    context "an existing cas user logs into plos", vcr: { cassette_name: 'ned' } do

      let(:user) { FactoryGirl.create(:user, :cas, email: 'email@example.com', password: "abcd1234", password_confirmation: "abcd1234") }
      let(:credential) { user.credentials.first }

      it "will not autogenerate a password" do
        allow_any_instance_of(TahiDevise::OmniauthCallbacksController).to receive(:auth).and_return(auth_hash)
        allow_any_instance_of(User).to receive(:password_required?).and_return(false)
        prev_password = user.encrypted_password
        get :cas
        expect(user.reload.encrypted_password).to eq(prev_password)
      end

      it "will redirect to dashboard" do
        allow_any_instance_of(TahiDevise::OmniauthCallbacksController).to receive(:auth).and_return(auth_hash)
        allow_any_instance_of(User).to receive(:password_required?).and_return(false)
        get :cas
        expect(response).to redirect_to root_path
      end

      context "with a mixed case email" do
        let(:auth_hash) { { provider: :cas, uid: cas_id, extra: { firstName: "Bill", lastName: "Jones", emailAddress: "eMail@example.com", displayName: "bjones", nedId: 12345 } } }
        it "will find a credentialless user even when NED sends mixed case emails" do
          allow_any_instance_of(TahiDevise::OmniauthCallbacksController).to receive(:auth).and_return(auth_hash)
          user.credentials.destroy_all
          get :cas
          expect(response).to redirect_to root_path
          expect(user.credentials.count).to eq(1)
        end
      end
    end
  end
end
