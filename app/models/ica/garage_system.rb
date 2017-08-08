# frozen_string_literal: true

require 'models/concerns/persisted_workflow'

module ICA
  # Used to identify who is calling in to the API
  class GarageSystem < ICA::ApplicationRecord
    validates :client_id, presence: true, length: { minimum: 6 }
    validates :sig_key, presence: true, format: /\A[0-9a-f]{64}\Z/
    validates :auth_key, presence: true, format: /\A[0-9a-f]{64}\Z/

    has_many :carparks, inverse_of: :garage_system

    include PersistedWorkflow

    workflow do
      state :prepared do
        event :go_live, transitions_to: :live
      end

      state :live do
        event :suspend, transitions_to: :suspended
      end

      state :suspended do
        event :go_live, transitions_to: :live
      end
    end
  end
end
