module UtilityService
  module North
    class ResponseMapper < UtilityService::ResponseMapper
      def retrieve_books(_response_code, response_body)
        { books: map_books(response_body['libros']) }
      end

      def retrieve_notes(_response_code, response_body)
        { notes: map_notes(response_body['notas']) }
      end

      private

      def map_books(books)
        books.map do |book|
          {
            id: book['id'],
            title: book['titulo'],
            author: book['autor'],
            genre: book['genero'],
            image_url: book['imagen_url'],
            publisher: book['editorial'],
            year: book['año']
          }
        end
      end

      def map_notes(notes)
        notes.map do |note|
          {
            title: note['titulo'],
            type: note['tipo'],
            created_at: note['fecha_creacion'],
            content: note['contenido'],
            user: {
              email: note['autor']['datos_de_contacto']['email'],
              first_name: note['autor']['datos_personales']['nombre'],
              last_name: note['autor']['datos_personales']['apellido']
            },
            book: {
              title: note['libro']['titulo'],
              author: note['libro']['autor'],
              genre: note['libro']['genero']
            }
          }
        end
      end
    end
  end
end
