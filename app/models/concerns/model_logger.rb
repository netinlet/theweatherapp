# for activemodel::api models where no logger is provided
module ModelLogger
  extend ActiveSupport::Concern

  included do
    def self.logger
      Rails.logger
    end
  end

  def logger
    Rails.logger
  end
end
