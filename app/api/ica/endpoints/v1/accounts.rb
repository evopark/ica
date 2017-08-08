# frozen_string_literal: true

module ICA::Endpoints::V1
  # Allows the remote to retrieve information about a single user account
  class Accounts < Grape::API
    namespace 'accounts' do
      get ':account_key' do
        # TODO: implement this
        status :not_found
        {}
      end
    end
  end
end
