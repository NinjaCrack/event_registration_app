class RegistrationsController < ApplicationController
    before_action :set_event
    before_action :set_registration, only: %i[edit update destroy]
    before_action :authorize_manage_registration!, only: %i[edit update destroy]

    def create
        unless @event.open_for_registration? 
            redirect_to @event, alert: "Registrations are closed for this event."
            return
        end

        @registration = @event.registrations.build(registration_params)
        @registration.user = current_user if user_signed_in?

        if @registration.save
            redirect_to @event, notice: "Registered successfully."
        else
            @registrations = @event.registrations.order(created_at: :desc)
            render 'events/show', status: :unprocessable_entity
        end
    end

    def edit; end

    def update
        if @registration.update(registration_params)
            redirect_to @event, notice: "Registration updated successfully."
        else
            render :edit, status: :unprocessable_entity
        end
    end

    def destroy
        @registration.destroy
        redirect_to @event, notice: "Registration removed."
    end

    private

    def set_event
        @event = Event.find(params[:event_id])
    end

    def set_registration
        @registration = @event.registrations.find(params[:id])
    end

    def authorize_manage_registration!
        return if current_user&.admin? || @registration.user == current_user || @event.user == current_user

        redirect_to @event, alert: "Not authorized to manage this registration."
    end

    def registration_params
        params.require(:registration).permit(:attendee_name, :attendee_email)
    end
end