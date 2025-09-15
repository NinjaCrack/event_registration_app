class Event < ApplicationRecord
  belongs_to :user

  # Associations
  has_many :registrations, dependent: :destroy

  # Validations
  validates :name, presence: true, length: { maximum: 200 }
  validates :status, presence: true, inclusion: { in: %w[open closed] }

  scope :open_events, -> { where('date >= ?', Date.current).order(date: :asc) } # Scope to get upcoming events
  scope :past, -> { where('date < ?', Date.current).order(date: :desc) } # Scope to get past events

  def open_for_registration?
    status == 'open'
  end
  
end
