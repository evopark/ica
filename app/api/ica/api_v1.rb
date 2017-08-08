# frozen_string_literal: true

module ICA
  # Entry point for the mobile JSON-based API, powered by Grape
  class ApiV1 < Grape::API
    version 'v1', using: :path

    mount ICA::Endpoints::V1::Accounts
    mount ICA::Endpoints::V1::Cards
    mount ICA::Endpoints::V1::Transactions
    mount ICA::Endpoints::V1::Command
  end
end
