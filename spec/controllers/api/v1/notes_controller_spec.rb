require 'rails_helper'

shared_examples 'a valid response' do
  it 'responds with the expected attributes' do
    expect(response_keys).to all(be_in(expected_attributes))
  end

  it 'responds with 200 status' do
    expect(response).to have_http_status(:ok)
  end
end

shared_examples 'not found resource' do
  it 'responds with 404 status' do
    expect(response).to have_http_status(:not_found)
  end
end

describe Api::V1::NotesController, type: :controller do
  let(:other_user) { create(:user) }

  describe 'GET #index' do
    let(:user_note_count) { Faker::Number.between(from: 1, to: 10) }
    let(:other_user_note_count) { Faker::Number.between(from: 1, to: 10) }
    let(:page_size) { Faker::Number.between(from: 1, to: user_note_count) }
    let(:page) { Faker::Number.between(from: 1, to: (user_note_count / page_size)) }
    let(:note_type_to_search) { Note.note_types.keys.sample }
    let(:required_params) do
      {
        note_type: note_type_to_search,
        page: page,
        page_size: page_size,
        order: %i[desc asc].sample
      }
    end

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      context 'when fetching notes with all required params' do
        let(:expected) do
          Note.where(
            user_id: user.id,
            note_type: required_params[:note_type]
          )
              .order(created_at: required_params[:order])
              .with_pagination(required_params[:page], required_params[:page_size])
        end

        let(:expected_attributes) { %w[id title note_type content_length] }
        let(:response_keys) { response_body.sample.keys }

        before do
          create(:note, user: user, note_type: note_type_to_search)
          create_list(:note, other_user_note_count, user: other_user)
          create_list(:note, user_note_count, user: user)

          get :index, params: required_params
        end

        it 'responds with the expected resource ammount' do
          expect(response_body.size).to eq(expected.size)
        end

        it_behaves_like 'a valid response'
      end

      context 'when fetching notes with a missing required param' do
        let(:missing_param)  { required_params.keys.sample }

        before { get :index, params: required_params.except(missing_param) }

        it_behaves_like 'bad request when a parameter is missing'
      end

      context 'when fetching notes with an invalid note type' do
        let(:invalid_note_type) { :invalid_type }

        before { get :index, params: required_params.merge(note_type: invalid_note_type) }

        it 'returns status code unprocessable entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when fetching notes and there are none' do
        let(:empty_notes) { [] }
        let(:expected_attributes) { [] }
        let(:response_keys) { response_body.empty? ? [] : response_body.sample.keys }

        before do
          allow(Note).to receive(:where).and_return(empty_notes)
          get :index, params: required_params
        end

        it 'responds with an empty array' do
          expect(response_body).to be_empty
        end

        it_behaves_like 'a valid response'
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
        let(:response_keys) { response_body.keys }
        let(:expected) { note }
        let(:expected_attributes) { %w[id title note_type word_count created_at content content_length user] }

        before { get :show, params: { id: note.id } }

        it_behaves_like 'a valid response'
      end

      context 'when fetching an invalid note' do
        let(:non_existent_note_id) { Note.maximum(:id).to_i + 1 }

        before { get :show, params: { id: non_existent_note_id } }

        it_behaves_like 'not found resource'
      end

      context 'when fetching another user\'s note' do
        let(:other_user_note) { create(:note, user: other_user) }

        before { get :show, params: { id: other_user_note.id } }

        it_behaves_like 'not found resource'
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

      context 'when creating a note' do
        let(:note_params) { attributes_for(:note) }

        before { post :create, params: { note: note_params } }

        it 'responds with the created note' do
          expect(response_body['message']).to eq(I18n.t('notes_create_success'))
        end

        it 'responds with 201 status' do
          expect(response).to have_http_status(:created)
        end
      end

      context 'when creating an invalid note' do
        let(:note_params) { { title: nil } }

        before { post :create, params: { note: note_params } }

        it 'responds with 400 status' do
          expect(response).to have_http_status(:bad_request)
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
