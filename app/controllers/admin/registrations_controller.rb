require 'csv'

class Admin::RegistrationsController < Admin::BaseController
  def index
    @registrations = Registration.includes(:event, :user).order(created_at: :desc)
    if params[:q].present?
      q = "%#{params[:q]}%"
      @registrations = @registrations.joins(:event).where("registrations.attendee_name ILIKE ? OR registrations.attendee_email ILIKE ? OR events.name ILIKE ?", q, q, q)
    end
  end

  def export_csv
    registrations = Registration.includes(:event)
    csv = CSV.generate(headers: true) do |csv|
      csv << %w[event_name attendee_name attendee_email registered_at user_id]
      registrations.find_each do |r|
        csv << [r.event.name, r.attendee_name, r.attendee_email, r.created_at.iso8601, r.user_id]
      end
    end
    send_data csv, filename: "registrations-#{Date.today}.csv"
  end

  def bulk_delete
    ids = params[:ids] || []
    Registration.where(id: ids).delete_all
    redirect_to admin_registrations_path, notice: "Deleted #{ids.size} registrations"
  end

  def destroy
    registration = Registration.find(params[:id])
    registration.destroy
    redirect_to admin_registrations_path, notice: 'Deleted'
  end
end
