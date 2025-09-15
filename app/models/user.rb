class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :events, dependent: :destroy
  has_many :registrations, dependent: :nullify

  # Validations
  validates :name, presence: true, length: { maximum: 100 }
  
  def admin?
    is_admin
  end

end
