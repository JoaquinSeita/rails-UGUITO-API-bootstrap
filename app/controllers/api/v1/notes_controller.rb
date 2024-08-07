module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!
      rescue_from ActionController::ParameterMissing, with: :render_missing_parameter_error
      rescue_from ActiveRecord::RecordInvalid, with: :note_create_validation_error

      def create
        return render_invalid_note_type if invalid_note_type?(create_note_parameters[:note_type])
        create_note_and_render_success
      end

      def index
        return render_invalid_note_type if invalid_note_type?(params.require(:note_type))
        return render_invalid_order if invalid_order?
        render json: notes, status: :ok, each_serializer: BriefNoteSerializer
      end

      def show
        render json: note, status: :ok, serializer: NoteSerializer
      end

      private

      def create_note_and_render_success
        create_note
        render json: { message: I18n.t('success.messages.note.create_success') }, status: :created
      end

      def create_note
        Note.create!(params.require(:note).permit(:title, :content, :note_type)
                           .merge(user_id: current_user.id))
      end

      def create_note_parameters
        require_nested(required_create_note_params, params)
        params.require(:note).permit(:title, :content, :note_type)
      end

      def required_create_note_params
        { note: { note_type: true, title: true, content: true } }
      end

      def note
        current_user.notes.find(params.require(:id))
      end

      def invalid_order?
        !%w[asc desc].include?(params.require(:order))
      end

      def invalid_note_type?(note_type)
        Note.note_types.keys.exclude?(note_type)
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

      def render_missing_parameter_error
        render json: { error: I18n.t('errors.messages.note.missing_param') }, status: :bad_request
      end

      def note_create_validation_error
        threshold = current_user.utility.short_threshold
        error_message = I18n.t('errors.messages.note.invalid_content_length', threshold: threshold)
        render json: { error: error_message }, status: :unprocessable_entity
      end
    end
  end
end
