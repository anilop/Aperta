require 'rails_helper'

describe CardVersionsController do
  let(:user) { FactoryGirl.create(:user) }

  describe '#show' do
    subject(:do_request) do
      get :show, format: 'json', id: card_version.id
    end
    let(:card_version) { FactoryGirl.create(:card_version) }
    let(:card) { card_version.card }
    let(:task) { FactoryGirl.create(:task, title: 'Competing Interests') }

    it_behaves_like 'an unauthenticated json request'

    context 'and the user is signed in' do
      context 'when the user does not have access' do
        before do
          stub_sign_in(user)
          allow(user).to receive(:can?)
            .with(:view, card_version)
            .and_return(false)
          do_request
        end

        it { is_expected.to responds_with(403) }
      end

      context 'user has access' do
        before do
          stub_sign_in user
          allow(user).to receive(:can?).with(:view, card_version).and_return(true)
        end

        it { is_expected.to responds_with 200 }

        it 'returns the card version' do
          do_request
          expect(res_body['card_version']['id']).to be card_version.id
        end
      end

      context 'and task associated with card version is present' do
        before do
          allow(Task).to receive_message_chain('joins.find_by').and_return(task)
        end

        context 'when user does not have access' do
          before do
            stub_sign_in(user)
            allow(user).to receive(:can?)
              .with(:view, task)
              .and_return(false)
            do_request
          end

          it { is_expected.to responds_with(403) }
        end

        context 'when user has access' do
          before do
            stub_sign_in user
            allow(user).to receive(:can?).with(:view, task).and_return(true)
          end

          it { is_expected.to responds_with 200 }

          it 'returns the card version' do
            do_request
            expect(res_body['card_version']['id']).to be card_version.id
          end
        end
      end
    end
  end
end
