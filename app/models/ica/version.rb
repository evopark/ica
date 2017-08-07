# frozen_string_literal: true

module ICA
  # Custom papertrail version model to keep it in a separate table
  class Version < PaperTrail::Version
  end
end
