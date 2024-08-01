module Api
  module V1
    class NotesController < ApplicationController
      rescue_from ArgumentError, with: :handle_invalid_parameter
      rescue_from ActionController::ParameterMissing, with: :handle_missing_parameter

      def index
        render json: notes_filtered, status: :ok, each_serializer: BriefNoteSerializer
      end

      def show
        render json: note, status: :ok, serializer: NoteSerializer
      end

      private

      def order
        raise(ArgumentError, I18n.t('invalid_order_error')) unless %w[asc
                                                                      desc].include?(params.require(:order))
        params.require(:order)
      end

      def note_type
        raise(ArgumentError, I18n.t('invalid_note_type_error')) unless %w[review
                                                                          critique].include?(params.require(:note_type))
        params.require(:note_type)
      end

      def notes_filtered
        Note.with_note_type(note_type).order(created_at: order)
            .with_pagination(params.require(:page), params.require(:page_size))
      end

      def note
        Note.find(params.require(:id))
      end

      def handle_missing_parameter(exception)
        render json: { error: exception.message }, status: :bad_request
      end

      def handle_invalid_parameter(exception)
        render json: { error: exception.message }, status: :unprocessable_entity
      end
    end
  end
end
