class NorthUtility < Utility
  def max_content_word_count
    { 'review' => 50 }
  end

  def content_thresholds
    { 'short' => 50, 'medium' => 100 }
  end
end
