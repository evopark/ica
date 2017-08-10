# frozen_string_literal: true

module ICA
  # Uploads a full export of account information to the remote system
  class FullAccountUpload
    include Sidekiq::Worker

    def perform(garage_system_id)
      @garage_system = ICA::GarageSystem.find(garage_system_id)
    end

    private

    def all_user_data
      facade.all_permitted_users.each do |user_data|
        if @garage_system.expose_easy_to_park? && easy_to_park?(user_data)

        end
      end
    end

    def easy_to_park?(user_data)
      user_data['brand'] == 'easy_to_park'
    end

    def facade
      @facade ||= ICA.garage_system_facade_class.new
    end
  end
end
