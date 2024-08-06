module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def index
        return render_invalid_note_type if invalid_note_type?
        return render_invalid_order if invalid_order?

        render json: notes, status: :ok, each_serializer: BriefNoteSerializer
      end

      def show
        render json: note, status: :ok, serializer: NoteSerializer
      end

      private

      def note
        current_user.notes.find(params.require(:id))
      end

      def invalid_order?
        !%w[asc desc].include?(params.require(:order))
      end

      def invalid_note_type?
        Note.note_types.keys.exclude?(params.require(:note_type))
      end

      def notes
        current_user.notes.with_note_type(params[:note_type]).order(created_at: params[:order])
                    .with_pagination(params.require(:page), params.require(:page_size))
      end

      def render_invalid_parameter_error(message)
        render json: { error: message }, status: :unprocessable_entity
      end

      def render_invalid_note_type
        render_invalid_parameter_error(I18n.t('errors.messages.note.invalid_note_type'))
      end

      def render_invalid_order
        render_invalid_parameter_error(I18n.t('errors.messages.note.invalid_order'))
      end
    end
  end
end
