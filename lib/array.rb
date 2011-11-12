class Array
  def hashing_by(fname)
    rec = {}
    self.each do |r|
      r.respond_to? fname.to_s or return nil
      rec[r.send(fname.to_s)] = r
    end
    rec
  end
end