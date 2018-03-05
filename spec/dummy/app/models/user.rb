# frozen_string_literal: true

# Simple user model to mimic the behaviour of the host application
class User < ApplicationRecord
  has_paper_trail only: %i[email]

  belongs_to :customer
end
