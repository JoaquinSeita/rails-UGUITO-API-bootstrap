require 'rails_helper'
shared_examples 'returns expected result' do
  it 'responds with the expected notes' do
    expect(response_body.to_json).to eq(expected)
  end

  it 'responds with 200 status' do
    expect(response).to have_http_status(:ok)
  end
end

shared_examples 'returns 404' do
  it 'responds with 404 status' do
    expect(response).to have_http_status(:not_found)
  end
end

describe Api::V1::NotesController, type: :controller do
  let(:other_user) { create(:user) }
  let(:other_user_note_count) { Faker::Number.between(from: 1, to: 100) }
  let(:other_user_notes) { create_list(:note, other_user_note_count, user: other_user) }
  let(:user_note_count) { Faker::Number.between(from: 1, to: 100) }
  let(:user_notes) { create_list(:note, user_note_count, user: user) }

  describe 'GET #index' do
    let(:page)       { 1 }
    let(:page_size)  { Faker::Number.between(from: 1, to: 100) }
    let(:required_params)    { { note_type: %i[review critique].sample, page: page, page_size: page_size, order: %i[desc asc].sample } }

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let(:expected) do
        ActiveModel::Serializer::CollectionSerializer.new(notes_expected,
                                                          serializer: BriefNoteSerializer).to_json
      end

      context 'when fetching notes with all required params' do
        before { get :index, params: required_params }

        let(:notes_expected) { Note.where(note_type: required_params[:note_type]).order(created_at: required_params[:order]).with_pagination(required_params[:page], required_params[:page_size]) }

        it_behaves_like 'returns expected result'
      end

      context 'when fetching notes with a missing required param' do
        let(:missing_param)  { required_params.keys.sample }

        before { get :index, params: required_params.except(missing_param) }

        it 'returns status code bad request' do
          expect(response).to have_http_status(:bad_request)
        end
      end

      context 'when fetching notes with an invalid note type' do
        let(:invalid_note_type) { :invalid_type }

        before { get :index, params: required_params.merge(note_type: invalid_note_type) }

        it 'returns status code unprocessable entity' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
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
        let(:note) { user_notes.sample }
        let(:expected) { NoteSerializer.new(note).to_json }

        before { get :show, params: { id: note.id } }

        it_behaves_like 'returns expected result'
      end

      context 'when fetching an invalid note' do
        let(:note) { create(:note) }

        before { get :show, params: { id: note.id } }

        it_behaves_like 'returns 404'
      end

      context 'when fetching another user\'s note' do
        let(:other_user_note) { other_user_notes.sample }

        before { get :show, params: { id: other_user_note.id } }

        it_behaves_like 'returns 404'
      end
    end

    context 'when there is not a user logged in' do
      context 'when fetching a note' do
        before { get :show, params: { id: Faker::Number.number } }

        it_behaves_like 'unauthorized'
      end
    end
  end
end
