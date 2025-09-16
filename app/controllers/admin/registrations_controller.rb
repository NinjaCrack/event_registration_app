require "csv"

class Admin::RegistrationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    @registrations = Registration.includes(:event).order(created_at: :desc)
    if params[:search].present?
      query = "%#{params[:search]}%"
      @registrations = @registrations.joins(:event).where(
        "registrations.attendee_name ILIKE :q
        OR registrations.attendee_email ILIKE :q
        OR events.name ILIKE :q
        OR events.location ILIKE :q",
        q: query
      )
    end
  end


  def bulk
    case params[:commit]
    when "Bulk Delete"
      Registration.where(id: params[:registration_ids]).destroy_all
      redirect_to admin_registrations_path, notice: "Selected registrations deleted."
    when "Export CSV"
      @registrations = Registration.includes(:event).order(created_at: :desc)

      csv_data = CSV.generate(headers: true) do |csv|
        csv << [ "Event", "Attendee Name", "Attendee Email", "Registered At" ]
        @registrations.each do |reg|
          csv << [ reg.event.name, reg.attendee_name, reg.attendee_email, reg.created_at ]
        end
      end

      send_data csv_data, filename: "registrations-#{Date.today}.csv"
    end
  end

  private

  def require_admin!
    redirect_to root_path, alert: "Access denied." unless current_user&.admin?
  end
end
