class WelcomeController < ApplicationController
  def index
    ActiveSupport::Notifications.instrument("where", here: 'welcome#index')
  end

  def form_template
  	# created for generic form template access at '/templates/form-template'
  end
end
