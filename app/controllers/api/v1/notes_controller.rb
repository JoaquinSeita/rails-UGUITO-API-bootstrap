module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def index
        render_index_response
      end

      def show
        render json: note, status: :ok, serializer: NoteSerializer
      end

      private

      def note
        Note.find(params.require(:id))
      end

      def render_index_response
        if invalid_parameter?
          render_error_message
        else
          render_ok
        end
      end

      def render_error_message
        if invalid_order?
          render_invalid_parameter_error(I18n.t('invalid_order_error'))
        elsif invalid_note_type?
          render_invalid_parameter_error(I18n.t('invalid_note_type_error'))
        end
      end

      def render_ok
        render json: notes_filtered, status: :ok, each_serializer: BriefNoteSerializer
      end

      def invalid_parameter?
        invalid_order? || invalid_note_type?
      end

      def invalid_order?
        !%w[asc desc].include?(params.require(:order))
      end

      def invalid_note_type?
        !%w[review critique].include?(params.require(:note_type))
      end

      def notes_filtered
        notes.with_note_type(params[:note_type]).order(created_at: params[:order])
             .with_pagination(params.require(:page), params.require(:page_size))
      end

      def render_invalid_parameter_error(message)
        render json: { error: message }, status: :unprocessable_entity
      end

      def notes
        current_user.notes
      end
    end
  end
end
