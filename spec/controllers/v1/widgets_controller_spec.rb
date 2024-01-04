require 'rails_helper'

RSpec.describe V1::WidgetsController, type: :controller do
  context 'when logged in' do
    let(:user) { create(:user) }

    before { authenticate(user) }

    describe '#index' do
      context 'when the user has widgets' do
        before do
          create_list(:widget, 5) # Not user's widgets
          create_list(:widget, 3, user: user)
        end

        it 'returns a list of widgets belonging to the current user' do
          get 'index'
          expect(payload.size).to eq(3)
        end
      end
    end

    describe '#show' do
      context 'with own widget' do
        let(:widget) { create(:widget, user: user) }

        it 'renders the widget' do
          get :show, params: { id: widget.uid }
          expect(payload['name']).to eq(widget.name)
        end
      end

      context 'with a different user widget' do
        let(:widget) { create(:widget) }

        it 'is denied' do
          get :show, params: { id: widget.uid }
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context 'with completely bogus id' do
        it 'is not found' do
          get :show, params: { id: '911' }
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe '#create' do
      it 'succeeds' do
        post :create, params: { widget: { name: 'Thing1', multiplier: 84 } }
        expect(response).to be_successful
      end

      it 'creates a widget' do
        expect do
          post :create, params: { widget: { name: 'Thing1', multiplier: 84 } }
        end.to change(Widget, :count).by(1)
      end

      it 'sets the name' do
        post :create, params: { widget: { name: 'Thing1', multiplier: 84 } }
        expect(payload['name']).to eq('Thing1')
      end

      it 'sets the multiplier' do
        post :create, params: { widget: { name: 'Thing1', multiplier: 84 } }
        expect(payload['multiplier']).to eq('84.0')
      end

      it 'does not set the aasm_state' do
        post :create, params: { widget: { name: 'Thing1', multiplier: 84, aasm_state: 'broken' } }
        expect(payload['status']).to eq('in_service')
      end

      it 'sets the user_id to the current user' do
        post :create, params: { widget: { name: 'Thing1', multiplier: 84, user_id: 99 } }
        uid = payload['id']
        expect(Widget.find(uid).user).to eq(user)
      end
    end

    describe '#update' do
      context 'with own widget' do
        let(:initial_name) { 'Spud' }
        let(:widget) { create(:widget, user: user, name: initial_name) }

        it 'can update multiplier' do
          patch :update, params: { id: widget.uid, widget: { multiplier: widget.multiplier + 100 } }
          expect(Widget.find(widget.id).multiplier).to eq(widget.multiplier + 100)
        end

        it 'cannot update name' do
          patch :update, params: { id: widget.uid, widget: { name: 'Cecil' } }
          expect(widget.name).to eq(initial_name)
        end

        it 'cannot update aasm_state' do
          patch :update, params: { id: widget.uid, widget: { aasm_state: 'broken' } }
          expect(widget.aasm_state).to eq(Widget.new.aasm_state)
        end
      end

      context 'with a different user widget' do
        let(:widget) { create(:widget) }

        it 'is denied' do
          patch :update, params: { id: widget.uid, widget: { multiplier: widget.multiplier + 100 } }
          expect(response).to have_http_status(:unauthorized)
        end

        it 'does not alter the widget' do
          patch :update, params: { id: widget.uid, widget: { multiplier: widget.multiplier + 100 } }
          expect(Widget.find(widget.id).multiplier).to eq(widget.multiplier)
        end
      end

      context 'with a bogus id' do
        it 'is not found' do
          patch :update, params: { id: 'BEEF', widget: { multiplier: 88.3 } }
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe '#destroy' do
      context 'with own widget' do
        let!(:widget) { create(:widget, user: user) }

        it 'succeeds' do
          delete :destroy, params: { id: widget.uid }
          expect(response).to be_successful
        end

        it 'deletes the widget' do
          expect do
            delete :destroy, params: { id: widget.uid }
          end.to change(Widget, :count).by(-1)
        end
      end

      context 'with a different user widget' do
        let!(:widget) { create(:widget) }

        it 'is denied' do
          delete :destroy, params: { id: widget.uid }
          expect(response).to have_http_status(:unauthorized)
        end

        it 'does not alter the widget' do
          expect do
            delete :destroy, params: { id: widget.uid }
          end.not_to change(Widget, :count)
        end
      end

      context 'with a bogus id' do
        it 'is not found' do
          delete :destroy, params: { id: 'BEEF' }
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
