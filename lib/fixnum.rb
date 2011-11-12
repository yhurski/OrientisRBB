class Fixnum
  def to_bool
    return false if self <= 0
    true
  end
end