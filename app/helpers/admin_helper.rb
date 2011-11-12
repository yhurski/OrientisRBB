module AdminHelper
  def String.to_bool
    this.to_i == 0 ? false : true
  end
end
