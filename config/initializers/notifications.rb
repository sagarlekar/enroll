require 'acapi/subscribers/base'
require 'acapi/subscribers/enterprise_logger'

ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
  Rails.logger.debug(["notification:", name, start, finish, id, payload].join(" "))
end

ActiveSupport::Notifications.subscribe "where" do |name, start, finish, id, payload|
  Rails.logger.debug(["notification:", name, start, finish, id, payload].join(" "))
end 

Acapi::Subscribers::EnterpriseLogger.attach_to(:enroll)

