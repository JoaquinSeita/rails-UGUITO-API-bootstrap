module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def create
        render_create_message(new_note)
      end

      def index
        render_index_response
      end

      def show
        render json: note, status: :ok, serializer: NoteSerializer
      end

      private

      def new_note
        current_user.notes.create(params.require(:note)
                                                .permit(:title,
                                                        :content,
                                                        :note_type))
      end

      def render_create_message(resource)
        resource.errors.empty? ? render_created : validation_error(resource)
      end

      def render_created
        render json: { message: I18n.t('notes_create_success') }, status: :created
      end

      def note
        notes.find(params.require(:id))
      end

      def render_index_response
        if invalid_order?
          return render_invalid_parameter_error(I18n.t('errors.messages.invalid_order'))
        end
        if invalid_note_type?
          return render_invalid_parameter_error(I18n.t('errors.messages.invalid_note_type'))
        end

        render_ok
      end

      def render_ok
        render json: notes_filtered, status: :ok, each_serializer: BriefNoteSerializer
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
