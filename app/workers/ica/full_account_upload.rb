# frozen_string_literal: true

module ICA
  # Uploads a full export of account information to the remote system
  class FullAccountUpload
    include Sidekiq::Worker

    def perform(carpark_id); end
  end
end
