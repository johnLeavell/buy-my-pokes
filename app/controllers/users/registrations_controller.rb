class Users::RegistrationsController < Devise::RegistrationsController
    before_action :reject_if_honeypot_filled, only: :create

    private

    # Bots tend to fill in every visible-looking input. This field is hidden
    # from real users via CSS, so if it has a value the submission is spam.
    def reject_if_honeypot_filled
        if params.dig(:user, :nickname).present?
            redirect_to new_user_registration_path, alert: "Something went wrong. Please try again."
        end
    end
end
