require "yaml"
require "digest/sha1"
require "readline"
include Readline
require "pp"

module Bliki
  module Configuration
    def self.configure input, output
      raise "#{input} file does not exists" if !File.exists? input
      if File.exists? output
        print "#{output} file already exists. Overwrite? (y/N): "
        return if readline != 'y' 
      end
      own = update_hash YAML.load_file(input)
      File.open(output, "w+") { |f| f.puts own.to_yaml }
    end
  
    private
    def self.update_hash hash, prefix = nil
      if prefix
        puts "'#{prefix}' configuration:"
        indent = " " * 4
      end
      hash.each_pair do |k, v|
        if v.class != Hash
          print "#{indent}#{k} (default '#{v}'): "
          value = readline.chomp
          if value.length > 0
            if k == 'password'
              value = Digest::SHA1.hexdigest(value)
            end
            hash[k] = value
          end
        else
          hash[k] = update_hash v, k
        end
      end
      hash
    end
  end
end