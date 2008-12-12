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

class String
  # From Ruby Facets
  #
  # placed here because Dreamhost insists on not requiring facets correctly
  def titlecase
    gsub(/\b\w/){$&.upcase}
  end
end