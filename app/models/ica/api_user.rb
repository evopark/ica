# frozen_string_literal: true

module ICA
  # Used to identify who is calling in to the API
  class ApiUser < ApplicationRecord
    validates :client_id, presence: true, length: { minimum: 6 }
    validates :sig_key, presence: true, format: /\A[0-9a-f]{64}\Z/
    validates :auth_key, presence: true, format: /\A[0-9a-f]{64}\Z/
    has_many :carparks, inverse_of: :api_user
  end
end
