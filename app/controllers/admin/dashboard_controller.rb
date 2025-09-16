class Admin::DashboardController < Admin::BaseController
    def index
        @total_events = Event.count
        @total_attendees = Registration.count
        @recent_events = Event.left_joins(:registrations)
                          .group(:id)
                          .select('events.*, COUNT(registrations.id) AS attendees_count')
                          .order('attendees_count DESC')
                          .limit(10)
    end
end