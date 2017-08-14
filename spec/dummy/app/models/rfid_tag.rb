# frozen_string_literal: true

require 'models/concerns/persisted_workflow'

# Simple RFID tag class to mimic the behaviour of the host application
class RfidTag < ApplicationRecord
  has_paper_trail

  belongs_to :user
  has_many :blocklist_entries
  has_many :parking_card_add_ons

  scope :short_term_allowed, -> { }

  include PersistedWorkflow
  # the transitions aren't really used but still it's easier to keep in sync if we just copy&paste
  # the actual workflow definition
  workflow do
    state :unused do
      event :hand_out, transitions_to: :handed_out
      event :request, transitions_to: :requested
      event :invalidate, transitions_to: :inactive
    end

    state :handed_out do
      event :assign, transitions_to: :assigned
      event :activate, transitions_to: :active
      event :invalidate, transitions_to: :inactive
    end

    state :assigned do
      event :activate, transitions_to: :active
      event :unassign, transitions_to: :handed_out
    end

    state :requested do
      event :activate, transitions_to: :active
      event :cancel_request, transitions_to: :unused
      event :invalidate, transitions_to: :inactive
    end

    state :active do
      event :retire, transitions_to: :inactive,
            if: ->(tag) { !tag.parking? }
    end

    state :inactive do
      event :reactivate, transitions_to: :active
    end
  end
end