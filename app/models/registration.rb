class Registration < ApplicationRecord
  belongs_to :event
  belongs_to :user, optional: true # Allow null user for guest registrations

  # Validations
  validates :attendee_name, presence: true
  validates :attendee_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :attendee_email, uniqueness: { scope: :event_id, message: "has already registered for this event" }
  
end
