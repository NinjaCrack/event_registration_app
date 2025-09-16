module Admin
  class EventsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!
    before_action :set_event, only: [ :show, :edit, :update, :destroy ]

    def index
      # @events = Event.includes(:user, :registrations).order(created_at: :desc)
      @events = Event.all.order(date: :desc)
      if params[:search].present?
        # @events = @events.where("name ILIKE ? OR location ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
        query = "%#{params[:search]}%"
        @events = @events.where(
          "events.name ILIKE :q
          OR events.location ILIKE :q
          OR events.description ILIKE :q
          OR events.status ILIKE :q",
          q: query
        )

      end
    end

    def bulk
      event_ids = params[:event_ids]
      case params[:bulk_action]
      when "Bulk Delete"
        Event.where(id: event_ids).destroy_all
        redirect_to admin_events_path, notice: "Selected events were deleted."
      when "Bulk Close"
        Event.where(id: event_ids).update_all(status: "closed")
        redirect_to admin_events_path, notice: "Selected events were closed."
      else
        redirect_to admin_events_path, alert: "No action performed."
      end
    end

    def new
      @event = Event.new
    end

    def create
      @event = Event.new(event_params)
      if @event.save
        redirect_to admin_event_path(@event), notice: "Event created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end


    def show
      @event = Event.find(params[:id])
      @registration = @event.registrations.build
      @registrations = @event.registrations
    end

    def edit; end

    def update
      if @event.update(event_params)
        redirect_to admin_event_path(@event), notice: "Event updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @event.destroy
      redirect_to admin_events_path, notice: "Event deleted successfully."
    end


    private

    def event_params
      params.require(:event).permit(:name, :date, :location, :description, :status)
    end

    def set_event
      @event = Event.find(params[:id])
    end

    def require_admin!
      redirect_to root_path, alert: "Not authorized" unless current_user.is_admin?
    end
  end
end
