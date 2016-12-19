require 'digest/md5'

module Devise
  module Encryptable
    module Encryptors
      class Md5 < Base
        def self.digest(password, stretches, salt, pepper)
          str = [password, salt].flatten.compact.join
          Digest::MD5.hexdigest(str)
        end
      end
    end
  end

  def self.secure_compare(a ,b)
    Rails.logger.debug "secure_compare  a: #{a}, b: #{b}"
    return false if a.blank? || b.blank? || a.bytesize != b.bytesize
    l = a.unpack "C#{a.bytesize}"

    res = 0
    b.each_byte { |byte| res |= byte ^ l.shift }
    res == 0
  end
end