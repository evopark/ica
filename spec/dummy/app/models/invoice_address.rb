# frozen_string_literal: true

# Just a simple address without any inheritance
class InvoiceAddress < ApplicationRecord
  belongs_to :customer
  self.table_name = 'addresses'

  enum gender: %i[male female]
  enum academic_title: %i[dr prof prof_dr]
end
