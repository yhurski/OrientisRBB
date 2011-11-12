class String
  def nl_to_br
    self.gsub("\r\n", "<br>")
  end
    
  def lc
    return 0 if self.nil? || self.size == 0
    self.split("\r\n").count
  end
    
  def to_bool
    return false if self.blank?
    return false if self.size > 0 and self.gsub('0', '').blank?
    true
  end
end