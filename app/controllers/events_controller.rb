class EventsController < ApplicationController
    before_action :authenticate_user!, except: [ :index, :show ]
    before_action :set_event, only: %i[show edit update destroy]
    before_action :authorize_creator!, only: %i[edit update destroy]

    def index
        @upcoming_events = Event.open_events
        @past_events = Event.past
        @events = Event.order(date: :asc)
        if params[:q].present?
            q = "%#{params[:q]}"
            @events = @events.where("name ILIKE ? OR location ILIKE ?", q, q)
        end
    end

    def my_events
        if user_signed_in?
            @my_events = current_user.events.order(date: :asc)
        else
            redirect_to new_user_session_path, alert: "You need to sign in to view your events."
        end
    end

    def show
        @event = Event.find(params[:id])
        @registrations = @event.registrations.order(created_at: :desc)
        @registration = Registration.new
    end

    def new
        @event = current_user.events.build
    end

    def create
        @event = current_user.events.build(event_params)
        if @event.save
            redirect_to @event, notice: "Event created successfully."
        else
            render :new, status: :unprocessable_entity
        end
    end

    def edit; end

    def update
        if @event.update(event_params)
            redirect_to @event, notice: "Event updated successfully."
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @event.destroy
        redirect_to events_path, notice: "Event deleted successfully."
    end

    private

    def set_event
        @event = Event.find(params[:id])
    end

    def authorize_creator!
        return if current_user&.admin? || @event.user == current_user

        redirect_to events_path, alert: "You are not authorized to perform this action."
    end

    def event_params
        params.require(:event).permit(:name, :date, :location, :description, :status)
    end
end
