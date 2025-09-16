module Admin
  class EventsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    def index
      @events = Event.includes(:user, :registrations).order(created_at: :desc)
    end

    def bulk_close
      Event.where(id: params[:event_ids]).update_all(status: "closed")
      redirect_to admin_events_path, notice: "Selected events were closed."
    end

    def bulk_delete
      Event.where(id: params[:event_ids]).destroy_all
      redirect_to admin_events_path, notice: "Selected events were deleted."
    end

    private

    def require_admin!
      redirect_to root_path, alert: "Not authorized" unless current_user.is_admin?
    end
  end
end
