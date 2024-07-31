module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def index
        render json: notes_filtered, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok, serializer: NoteSerializer
      end

      private

      def filtering_params
        params.permit(%i[note_type])
      end

      def notes_filtered
        notes.where(filtering_params)
             .order(created_at: params[:order] || :desc)
             .page(params[:page])
             .per(params[:page_size])
      end

      def show_note
        notes.find(params.require(:id))
      end

      def notes
        current_user.notes
      end
    end
  end
end
