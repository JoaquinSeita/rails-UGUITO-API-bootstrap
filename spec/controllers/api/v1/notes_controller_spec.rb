require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let(:user_note_count) { Faker::Number.between(from: 1, to: 10) }
    let(:page_size) { Faker::Number.between(from: 1, to: user_note_count) }
    let(:page) { Faker::Number.between(from: 1, to: (user_note_count / page_size)) }
    let(:valid_required_params) do
      {
        note_type: Note.note_types.keys.sample,
        page: page,
        page_size: page_size,
        order: %i[desc asc].sample
      }
    end

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      context 'when fetching notes with all required params' do
        let(:random_index) { Faker::Number.between(from: 0, to: response_body.size - 1) }
        let(:expected_keys) { %w[id title note_type content_length] }
        let(:filtered_notes) { Note.where(user_id: user.id, note_type: valid_required_params[:note_type]) }
        let(:expected) do
          filtered_notes.order(created_at: valid_required_params[:order])
                        .with_pagination(valid_required_params[:page], valid_required_params[:page_size])
        end

        before do
          create(:note, note_type: valid_required_params[:note_type])
          create_list(:note, user_note_count, user: user, note_type: valid_required_params[:note_type])

          get :index, params: valid_required_params
        end

        it 'responds with ordered array' do
          expect(response_body[random_index]['id']).to eq(expected[random_index].id)
        end

        it_behaves_like 'paginated response'

        it_behaves_like 'valid array response'
      end

      context 'when fetching notes with a missing required param' do
        let(:missing_param)  { valid_required_params.keys.sample }

        before { get :index, params: valid_required_params.except(missing_param) }

        it_behaves_like 'bad request'

        it 'responds with the correct missing parameter error message' do
          expect(response_body['error']).to eq(I18n.t('errors.messages.note.missing_param'))
        end
      end

      context 'when fetching notes with an invalid note type' do
        let(:invalid_note_type) { :invalid_type }

        before { get :index, params: valid_required_params.merge(note_type: invalid_note_type) }

        it_behaves_like 'unprocessable entity response'
      end

      context 'when fetching notes and there are none' do
        before do
          get :index, params: valid_required_params
        end

        it_behaves_like 'valid empty array response'
      end
    end

    context 'when there is not a user logged in' do
      context 'when fetching all the notes for user' do
        before { get :index }

        it_behaves_like 'unauthorized'
      end
    end
  end

  describe 'GET #show' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      context 'when fetching a note' do
        let(:note) { create(:note, user: user) }
        let(:expected_keys) { %w[id title note_type word_count created_at content content_length user] }

        before { get :show, params: { id: note.id } }

        it_behaves_like 'valid object response'
      end

      context 'when fetching an invalid note' do
        before { get :show, params: { id: Faker::Number.number } }

        it_behaves_like 'not found response'
      end

      context 'when fetching another user\'s note' do
        let(:other_user_note) { create(:note) }

        before { get :show, params: { id: other_user_note.id } }

        it_behaves_like 'not found response'
      end
    end

    context 'when there is not a user logged in' do
      context 'when fetching a note' do
        before { get :show, params: { id: Faker::Number.number } }

        it_behaves_like 'unauthorized'
      end
    end
  end

  describe 'POST #create' do
    context 'when there is a user logged in' do
      include_context 'with authenticated user'
      let(:note_params) { attributes_for(:note) }

      context 'when creating a valid note' do
        let(:created_resource) { Note.where(note_params) }

        before { post :create, params: { note: note_params } }

        it_behaves_like 'successful create response'

        it 'responds the custom success message' do
          expect(response_body['message']).to eq(I18n.t('success.messages.note.create_success'))
        end
      end

      context 'when attempting to create a note with missing parameter' do
        let(:missing_param) { note_params.keys.sample }

        before { post :create, params: { note: note_params.except(missing_param) } }

        it 'responds with the correct missing parameter error message' do
          expect(response_body['error']).to eq(I18n.t('errors.messages.note.missing_param'))
        end

        it 'responds error status' do
          expect(response).to have_http_status(:bad_request)
        end
      end

      context 'when creating a note with an invalid note type' do
        let(:note_params) { attributes_for(:note).merge(note_type: :invalid_type) }

        before { post :create, params: { note: note_params } }

        it_behaves_like 'unprocessable entity response'

        it 'responds with the correct invalid note type error message' do
          expect(response_body['error']).to eq(I18n.t('errors.messages.note.invalid_note_type'))
        end
      end

      context 'when creating a note with type review and invalid content length' do
        let(:word_count) { Faker::Number.between(from: user.utility.short_threshold + 1) }
        let(:review_params) do
          note_params.merge(note_type: :review)
                     .merge(content: Faker::Lorem.sentence(word_count: word_count))
                     .merge(user_id: user.id)
        end

        before { post :create, params: { note: review_params } }

        it_behaves_like 'unprocessable entity response'

        it 'responds with the correct invalid content length error message' do
          expect(response_body['error']).to eq(I18n.t('errors.messages.note.invalid_content_length', threshold: user.utility.short_threshold))
        end
      end
    end

    context 'when there is not a user logged in' do
      context 'when creating a note' do
        before { post :create, params: { note: attributes_for(:note) } }

        it_behaves_like 'unauthorized'
      end
    end
  end
end
