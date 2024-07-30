class NorthUtility < Utility
  def note_is_short?(note)
    note.word_count <= 50
  end

  def note_is_medium?(note)
    words = note.word_count
    words > 50 && words <= 100
  end

  def note_is_long?(note)
    note.word_count > 100
  end
end
