# frozen_string_literal: true

# Simple representation of {Operator::Company} from the main application
class OperatorCompany < ApplicationRecord
  has_many :parking_garages
  has_and_belongs_to_many :test_groups
end
