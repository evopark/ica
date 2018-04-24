# frozen_string_literal: true

require 'models/concerns/persisted_workflow'

module ICA
  # Used to identify who is calling in to the API
  class GarageSystem < ICA::ApplicationRecord
    validates :client_id, presence: true, length: { minimum: 6 }, uniqueness: true
    validates :sig_key, presence: true, format: /\A[0-9a-f]{64}\Z/
    validates :auth_key, presence: true, format: /\A[0-9a-f]{64}\Z/
    validates :hostname, presence: true

    has_many :carparks, inverse_of: :garage_system
    has_many :parking_garages, through: :carparks
    has_many :blocklist_entries, through: :parking_garages
    has_many :blocked_rfid_tags, through: :blocklist_entries, source: :rfid_tag

    has_many :customer_account_mappings, class_name: 'ICA::CustomerAccountMapping'
    has_many :card_account_mappings, through: :customer_account_mappings

    enum variant: { easy_to_park: 'easy_to_park', ica: 'ica' }

    scope :with_client_id, ->(client_id) { where(client_id: client_id) }

    validates :path_prefix, format: { with: %r{\A/[\w/]+[^/]\Z} }, if: :path_prefix

    include PersistedWorkflow
    workflow do
      state :prepared do
        event :start_testing, transitions_to: :testing
      end

      state :testing do
        event :go_live, transitions_to: :live
      end

      state :live do
        event :suspend, transitions_to: :suspended
      end

      state :suspended do
        event :go_live, transitions_to: :live
      end
    end

    def to_s
      "#{client_id}@#{hostname}/#{variant}"
    end

    def test_groups
      return TestGroup.none if parking_garages.empty?
      test_groups = TestGroup.ica
      test_groups = test_groups.for_operator_company(parking_garages.first.operator_company)
      test_groups = test_groups.always if live?
      test_groups
    end
  end
end
