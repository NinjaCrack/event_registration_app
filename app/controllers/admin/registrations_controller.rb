require "csv"

class Admin::RegistrationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  # Make sure @registration is set before @event for actions that need both
  before_action :set_registration, only: [ :show, :edit, :update, :destroy ]
  before_action :set_event, only: [ :new, :create, :edit, :update ]

  # GET /admin/registrations
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

  # GET /admin/events/:event_id/registrations/new
  def new
    @registration = @event.registrations.build
    @registrations = @event.registrations
  end

  # POST /admin/events/:event_id/registrations
  def create
    @registration = @event.registrations.build(registration_params)
    if @registration.save
      redirect_to admin_event_path(@event), notice: "Registration created successfully."
    else
      @registrations = @event.registrations
      render "admin/events/show", status: :unprocessable_entity
    end
  end

  # GET /admin/events/:event_id/registrations/:id/edit
  def edit
    @registrations = @event.registrations
  end

  # PATCH/PUT /admin/events/:event_id/registrations/:id
  def update
    if @registration.update(registration_params)
      redirect_to admin_event_path(@event), notice: "Registration updated successfully."
    else
      @registrations = @event.registrations
      render "admin/events/show", status: :unprocessable_entity
    end
  end

  # DELETE /admin/registrations/:id
  def destroy
    event = @registration.event
    @registration.destroy
    redirect_to admin_event_path(event), notice: "Registration deleted."
  end

  # POST /admin/registrations/bulk
  def bulk
    registration_ids = params[:registration_ids] || []

    case params[:commit]
    when "Bulk Delete"
      if registration_ids.any?
        Registration.where(id: registration_ids).destroy_all
        redirect_to admin_registrations_path, notice: "Selected registrations deleted."
      else
        redirect_to admin_registrations_path, alert: "No registrations selected."
      end

    when "Export CSV"
      registration_ids = params[:registration_ids] || []

      @registrations = if registration_ids.any?
                        Registration.includes(:event).where(id: registration_ids)
      else
                        Registration.includes(:event) # All registrations if none selected
      end

      csv_data = CSV.generate(headers: true) do |csv|
        csv << [ "Event", "Attendee Name", "Attendee Email", "Registered At" ]
        @registrations.each do |reg|
          csv << [
            reg.event.name,
            reg.attendee_name,
            reg.attendee_email,
            reg.created_at.strftime("%Y-%m-%d %H:%M")
          ]
        end
      end

      send_data csv_data, filename: "registrations-#{Date.today}.csv", type: "text/csv"

    else
      redirect_to admin_registrations_path, alert: "No action performed."
    end
  end

  # GET /admin/events/:event_id/registrations/:id
  def show
    # @registration already set in before_action
  end

  private

  # Sets @event safely: either from params[:event_id] or @registration.event
  def set_event
    if params[:event_id]
      @event = Event.find(params[:event_id])
    elsif @registration
      @event = @registration.event
    else
      @event = nil
    end
  end

  # Sets @registration
  def set_registration
    @registration = Registration.find(params[:id]) if params[:id]
  end

  # Strong parameters
  def registration_params
    params.require(:registration).permit(:attendee_name, :attendee_email)
  end

  # Admin access check
  def require_admin!
    redirect_to root_path, alert: "Access denied." unless current_user&.admin?
  end
end
