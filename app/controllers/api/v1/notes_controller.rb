module Api
  module V1
    class NotesController < ApplicationController
      def index
        render json: notes_filtered, status: :ok, each_serializer: IndexNoteSerializer
      end

      def notes_filtered
        Note.where(filtering_params)
            .order(created_at: params[:order] || :desc)
            .page(params[:page])
            .per(params[:page_size])
      end

      def filtering_params
        params.permit(%i[note_type])
      end

      def show
        render json: show_note, status: :ok, serializer: NoteSerializer
      end

      def show_note
        Note.find(params.require(:id))
      end
    end
  end
end
