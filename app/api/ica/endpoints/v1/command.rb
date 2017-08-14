# frozen_string_literal: true

module ICA::Endpoints::V1
  # Enables the remote system to issue commands for specific actions
  class Command < Grape::API
    COMMANDS = {
      1 => :full_sync
    }.freeze

    namespace '/command' do
      desc 'Trigger a command on this system'
      params do
        requires :Command, type: Integer, values: COMMANDS.keys
      end
      post do
        case COMMANDS[params[:Command]]
        when :full_sync then ICA::FullAccountUpload.perform_async(garage_system.id)
        end
        body false
      end

      desc 'Alive/heartbeat endpoint'
      get do
        call_facade(:ping, garage_ids: garage_system.carparks.pluck(:parking_garage_id))
        body false
      end
    end
  end
end
