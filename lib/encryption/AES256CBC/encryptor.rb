require 'openssl'
module Encryption
  module AES256CBC
    class Encryptor

      def initialize plaintext
        @plaintext = plaintext
        @iv, @ciphertext = encrypt
      end

      def plaintext
        decrypt
      end

      def ciphertext
        @ciphertext
      end

      protected

      def encrypt
        aes = OpenSSL::Cipher::Cipher.new('AES-256-CBC')
        aes.encrypt # must be call before #key and #iv
        aes.key = Settings.encryption_key
        aes.iv = iv = aes.random_iv
        ciphertext = aes.update(@plaintext)
        ciphertext <<  aes.final
        return iv, ciphertext
      end

      def decrypt
        aes = OpenSSL::Cipher::Cipher.new('AES-256-CBC')
        aes.decrypt # must be called before aes.key aes.iv
        aes.key = Settings.encryption_key
        aes.iv = @iv
        plaintext = aes.update(@ciphertext)
        plaintext << aes.final
      end

    end
  end
end