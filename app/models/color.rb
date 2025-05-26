# == Schema Information
#
# Table name: colors
#
#  id         :bigint           not null, primary key
#  color_code :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_colors_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Color < ApplicationRecord
  belongs_to :user

  validates :color_code, presence: true
  validate :valid_color_code_format

  before_validation :normalize_color_code
  after_create :log_color_creation
  after_destroy :log_color_deletion

  private

  def valid_color_code_format
    unless color_code.match?(/\A#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})\z/)
      errors.add(:color_code, "must be a valid hex color code (e.g., #FF0000 or #F00)")
    end
  end

  def normalize_color_code
    self.color_code = color_code.upcase
    self.color_code = color_code.strip.upcase if color_code.present?

    if color_code&.match?(/\A#[A-Fa-f0-9]{3}\z/)
      self.color_code = color_code.gsub(/\A#([A-Fa-f0-9])([A-Fa-f0-9])([A-Fa-f0-9])\z/, '#\1\1\2\2\3\3')
    end
  end

  def log_color_creation
    Rails.logger.info("Color created: #{color_code} for user #{user_id}")
  end

  def log_color_deletion
    Rails.logger.info("Color deleted: #{color_code} for user #{user_id}")
  end
end
