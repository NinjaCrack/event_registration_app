class Admin::DashboardController < Admin::BaseController
    before_action :authenticate_user!
    before_action :require_admin!

    def index
        @total_events = Event.count
        @total_registrations = Registration.count
        # @recent_events = Event.left_joins(:registrations)
        #                   .group(:id)
        #                   .select('events.*, COUNT(registrations.id) AS attendees_count')
        #                   .order('attendees_count DESC')
        #                   .limit(10)
        @upcoming_events = Event.where("date >= ?", Date.today).count
        @past_events = Event.where("date < ?", Date.today).count
    end

    private
    def require_admin!
        redirect_to root_path, alert: "Not authorized" unless current_user&.admin?
    end
end
