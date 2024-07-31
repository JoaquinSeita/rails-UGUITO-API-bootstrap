require 'rails_helper'

def serialize_notes(notes)
  ActiveModel::Serializer::CollectionSerializer.new(notes, serializer: IndexNoteSerializer).to_json
end

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let(:user_notes) { create_list(:note, 5, user: user) }

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      let!(:expected) do
        serialize_notes(user_notes)
      end

      context 'when fetching all the notes for user' do
        let(:notes_expected) do
          serialize_notes(user_notes)
        end

        it 'responds with the expected notes json' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes with page and page size params' do
        let(:page)            { 1 }
        let(:page_size)       { 2 }
        let(:notes_expected) { serialize_notes(user_notes.first(2)) }

        before { get :index, params: { page: page, page_size: page_size } }

        it 'responds with the expected notes' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes using filters' do
        let(:note_type) { %w[review critique].sample }

        let!(:typed_notes) { create_list(:note, 2, user: user, note_type: note_type) }
        let(:notes_expected) { serialize_notes(typed_notes) }

        before { get :index, params: { note_type: note_type } }

        it 'responds with expected notes' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes using order param' do
        let(:notes_expected) { user_notes.order(created_at: :asc) }

        before { get :index, params: { order: :asc } }

        it 'responds with expected notes' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
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

        let(:note) { user_notes.sample }

        context 'when fetching a note' do
          let(:note_expected) { note }

          before { get :show, params: { id: note.id } }

          it 'responds with the expected note json' do
            expect(response_body.to_json).to eq(note_expected.to_json)
          end

          it 'responds with 200 status' do
            expect(response).to have_http_status(:ok)
          end
        end

        context 'when fetching an invalid note' do
          let(:note) { create(:note) }

          before { get :show, params: { id: note.id } }

          it 'responds with 404 status' do
            expect(response).to have_http_status(:not_found)
          end
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
end
