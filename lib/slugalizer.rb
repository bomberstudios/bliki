require "iconv"
class String
  def slugalize(separator = "-")
    re_separator = Regexp.escape("-")
    result = self.downcase
    # result = Iconv.iconv('ascii//ignore//translit', 'utf-8', self).to_s.downcase
    # result.gsub!(/(~n|~N)/,'n')
    result.gsub!(/(ñ|Ñ)/,'n')
    result.gsub!(/(á|Á)/,'a')
    result.gsub!(/(é|É)/,'e')
    result.gsub!(/(í|Í)/,'i')
    result.gsub!(/(ó|Ó)/,'o')
    result.gsub!(/(ú|Ú)/,'u')
    result.gsub!(/[¡¿!?':"]/,'')
    # result.gsub!(/[^\x00-\x7F]+/, '')                      # Remove non-ASCII (e.g. diacritics).
    result.gsub!(/[^a-z0-9\-_\+]+/i, separator)            # Turn non-slug chars into the separator.
    result.gsub!(/#{re_separator}{2,}/, separator)         # No more than one of the separator in a row.
    result.gsub!(/^#{re_separator}|#{re_separator}$/, '')  # Remove leading/trailing separator.
    result
  end
end