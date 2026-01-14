#!/usr/bin/env ruby

class CaesarCipher
  def initialize(shift)
    @shift = shift
    @uppercase_letters = ('A'..'Z').to_a
    @lowercase_letters = ('a'..'z').to_a
  end

  def encrypt(message)
    encrypted = ""
    message.each_char do |char|
      if @uppercase_letters.include?(char)
        encrypted += @uppercase_letters[(@uppercase_letters.index(char) + @shift) % 26]
      elsif @lowercase_letters.include?(char)
        encrypted += @lowercase_letters[(@lowercase_letters.index(char) + @shift) % 26]
      else
        encrypted += char
      end
    end
    encrypted
  end

  def decrypt(message)
    decrypted = ""
    message.each_char do |char|
      if @uppercase_letters.include?(char)
        decrypted += @uppercase_letters[(@uppercase_letters.index(char) - @shift) % 26]
      elsif @lowercase_letters.include?(char)
        decrypted += @lowercase_letters[(@lowercase_letters.index(char) - @shift) % 26]
      else
        decrypted += char
      end
    end
    decrypted
  end
end