class SouthUtility < Utility
  def note_is_short?(note)
    note.word_count <= 60
  end

  def note_is_medium?(note)
    words = note.word_count
    words > 60 && words <= 120
  end

  def note_is_long?(note)
    note.word_count > 120
  end
end
