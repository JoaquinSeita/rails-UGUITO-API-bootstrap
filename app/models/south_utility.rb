class SouthUtility < Utility
  def max_content_word_count
    { 'review' => 60 }
  end

  def content_thresholds
    { 'short' => 60, 'medium' => 120 }
  end
end
