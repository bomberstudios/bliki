module Enumerable
  def blank?
    return self.size <= 0
  end
end

class Symbol
  def blank?
    return self.to_s.size <= 0
  end
end