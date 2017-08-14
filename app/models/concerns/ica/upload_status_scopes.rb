# frozen_string_literal: true

module ICA
  # Adds `uploaded` and `not_uploaded` scopes to the model
  module UploadStatusScopes
    extend ActiveSupport::Concern

    included do
      scope :uploaded, -> { where.not(uploaded_at: nil) }
      scope :not_uploaded, -> { where(uploaded_at: nil) }
    end

    def uploaded?
      uploaded_at.present?
    end
  end
end
