# frozen_string_literal: true

# Utility to work with RFID tag TIDs
class RfidTid
  def initialize(tid)
    @tid = sanitize(tid)
  end

  def xtid?
    e2? && bit_set?(8)
  end

  def security?
    e2? && bit_set?(9)
  end

  def file?
    e2? && bit_set?(10)
  end

  def designer
    bits[11, 9].to_i
  end

  def model_number
    bits[20, 12].to_i
  end

  def to_s
    @tid
  end

  private

  def e2?
    @tid.starts_with?('E2')
  end

  def sanitize(tid)
    tid = tid.upcase
    return tid if plausible?(tid)
    tid.scan(/(\w{2})(\w{2})/).map(&:reverse).join.tap do |reversed|
      raise ArgumentError, 'Implausible TID' unless plausible?(reversed)
    end
  end

  def plausible?(tid)
    tid =~ /\AE2[0-9A-F]{22}\z/
  end

  def bit_set?(idx)
    bits[idx] == '1'
  end

  def bits
    @bits ||= @tid.to_i(16).to_s(2)
  end
end
