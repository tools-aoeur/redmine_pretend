# frozen_string_literal: true

require 'spec_helper'

describe PretendController, type: :controller do
  fixtures :users

  let(:admin) { User.find(1) }
  let(:target) { User.find(2) }
  let(:other) { User.find(3) }

  before do
    @controller = PretendController.new
    @request = ActionDispatch::TestRequest.create
    @response = ActionDispatch::TestResponse.new
    User.current = nil
    @request.session = ActionController::TestSession.new
    admin.update_columns(admin: true)
    target.update_columns(admin: false)
    other.update_columns(admin: false)
  end

  describe 'POST create' do
    context 'when an admin is not yet pretending' do
      before { session[:user_id] = admin.id }

      it 'switches the session to the target user and remembers the real user' do
        post :create, params: { id: target.id }

        expect(session[:user_id]).to eq target.id
        expect(session[:real_user_id]).to eq admin.id
        expect(response).to redirect_to(user_path(target))
      end
    end

    # Reproduces the 500 of 2026-10-05: a second POST (e.g. a double click on a
    # slow redirect) arrives when the session is already impersonating.
    context 'when the session is already pretending' do
      before do
        session[:user_id] = target.id
        session[:real_user_id] = admin.id
        target.update_columns(admin: true)
      end

      it 'does not raise' do
        expect { post :create, params: { id: target.id } }.not_to raise_error
      end

      it 'keeps the current impersonation untouched' do
        post :create, params: { id: target.id } rescue nil # rubocop:disable Style/RescueModifier

        expect(session[:user_id]).to eq target.id
        expect(session[:real_user_id]).to eq admin.id
      end

      it 'never replaces the remembered real user' do
        post :create, params: { id: other.id } rescue nil # rubocop:disable Style/RescueModifier

        expect(session[:real_user_id]).to eq admin.id
      end
    end

    context 'when the current user is not an admin' do
      before { session[:user_id] = target.id }

      it 'responds with 403 without raising' do
        expect { post :create, params: { id: other.id } }.not_to raise_error
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not impersonate anyone' do
        post :create, params: { id: other.id } rescue nil # rubocop:disable Style/RescueModifier

        expect(session[:user_id]).to eq target.id
        expect(session[:real_user_id]).to be_blank
      end
    end

    context 'when anonymous' do
      it 'responds with 403 without impersonating' do
        expect { post :create, params: { id: target.id } }.not_to raise_error
        expect(response).to have_http_status(:forbidden)
        expect(session[:real_user_id]).to be_blank
      end
    end
  end

  describe 'POST delete' do
    context 'when pretending' do
      before do
        session[:user_id] = target.id
        session[:real_user_id] = admin.id
      end

      it 'restores the real user and clears the remembered id' do
        post :delete

        expect(session[:user_id]).to eq admin.id
        expect(session[:real_user_id]).to be_nil
        expect(response).to be_redirect
      end
    end

    context 'when not pretending' do
      before { session[:user_id] = admin.id }

      it 'leaves the session alone' do
        post :delete

        expect(session[:user_id]).to eq admin.id
        expect(response).to be_redirect
      end
    end
  end
end
