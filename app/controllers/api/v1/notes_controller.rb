module Api
  module V1
    class NotesController < ApplicationController

      def index
        render json: notes_filtered, status: :ok, each_serializer: BriefNoteSerializer
      end

      def show
        render json: note, status: :ok, serializer: NoteSerializer
      end

      private

      def notes_filtered
        Note.with_note_type(note_type).order(created_at: order)
            .with_pagination(params.require(:page), params.require(:page_size))
      end

      def note
        Note.find(params.require(:id))
      end

      def order
        unless %w[asc desc].include?(params.require(:order))
          render_invalid_parameter(I18n.t('invalid_order_error'))
        end
        params.require(:order)
      end

      def note_type
        unless %w[review critique].include?(params.require(:note_type))
          render_invalid_parameter(I18n.t('invalid_note_type_error'))
        end
        params.require(:note_type)
      end

      def render_invalid_parameter(message)
        render json: { error: message }, status: :unprocessable_entity
      end
    end
  end
end
