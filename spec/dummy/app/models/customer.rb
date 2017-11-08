# frozen_string_literal: true

require 'models/concerns/persisted_workflow'

# Customer information, complementary to login-data from {User}
class Customer < ApplicationRecord
  has_one :user

  has_paper_trail

  has_many :rfid_tags
  has_and_belongs_to_many :test_groups
  has_many :invoice_addresses
  has_one :current_invoice_address, -> { where(default: true) }, class_name: 'InvoiceAddress'

  enum brand: { evopark: 'evopark', easy_to_park: 'easy_to_park' }

  include PersistedWorkflow

  # the transitions aren't really used but still it's easier to keep in sync if we just copy&paste
  # the actual workflow definition
  workflow do
    state :just_signed_up do
      event :enter_address_information, transitions_to: :waiting_for_payment
      event :terminate, transitions_to: :terminated
    end

    state :waiting_for_payment do
      event :register_payment_method, transitions_to: :unconfirmed
      event :change_payment_method, transitions_to: :unconfirmed
      event :terminate, transitions_to: :terminated
    end

    state :unconfirmed do
      event :change_payment_method, transitions_to: :waiting_for_payment
      event :confirm, transitions_to: :confirmed
      event :terminate, transitions_to: :terminated
    end

    state :confirmed do
      event :terminate, transitions_to: :terminating
    end
    state :terminating do
      event :finish_termination, transitions_to: :terminated
    end
    state :terminated
  end
end