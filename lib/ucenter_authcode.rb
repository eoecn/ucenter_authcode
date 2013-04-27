# coding: UTF-8

require 'digest/md5'
require 'base64'

module UCenter
  def self.decode key, string
    AuthCode.new.authcode(key, string)
  end

  # 用类包装来防止方法间变量修改
  class AuthCode
    KeyLength = 4

    # 参考 https://github.com/daxingplay/dokuwiki_ucenter/blob/master/api/uc.php#L295
    def authcode key, string
      # 拆分key，并各自做md5
      key = md5(key)
      key_left, key_right = md5(key[0, 16]), md5(key[16, 16])

      # 拆分string auth和content部分
      string_auth, string_content = string[0, KeyLength], string[KeyLength..-1]

      # 从key_crypt抽取box
      key_crypt = key_left + md5(key_left + string_auth)
      key_crypt_length = key_crypt.length
      rndkey = []
      0.upto(255) do |i|
        rndkey[i] = (key_crypt[i % key_crypt_length]).ord
      end
      a = b = 0
      box = (0..255).to_a
      while b < 256 do
        a = (a + box[b] + rndkey[b]) % 256
        box[b], box[a] = box[a], box[b]
        b +=1
      end

      # 联合key_crypt和key_content解密出result
      string_content_ords = base64_url_decode(string_content).bytes.to_a
      string_content_ords_length = string_content_ords.length
      a = b = string_idx = 0
      result = ""
      while string_idx < string_content_ords_length
        a = (a + 1) % 256
        b = (b + box[a]) % 256
        box[a], box[b] = box[b], box[a]
        result << (string_content_ords[string_idx] ^ (box[(box[a] + box[b]) % 256])).chr
        string_idx +=1
      end

      result_time_valided = (result[0, 10] == '0'*10) || (result[0, 10].to_i - Time.now.to_i  >  0)
      result_string_valided = result[10, 16] == md5("#{result[26..-1]}#{key_right}")[0, 16] # 重新加密和string对比验证
      if (result_time_valided  && result_string_valided)
        return result[26..-1]
      else
        return ''
      end
    end

    def microtime
      epoch_mirco = Time.now.to_f
      epoch_full = Time.now.to_i
      epoch_fraction = epoch_mirco - epoch_full
      epoch_fraction.to_s + ' ' + epoch_full.to_s
    end

    private
    def md5 str; Digest::MD5.hexdigest str.to_s end

    def base64_url_decode str
      mod = str.to_s.length.modulo(4)
      str2 = "#{str}#{'=' * (4 - mod)}".tr('-_','+/')
      Base64.decode64 str2
    end

  end
end
