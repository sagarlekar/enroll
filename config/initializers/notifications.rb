require 'acapi/subscribers/base'
require 'acapi/subscribers/enterprise_logger'
require 'acapi/subscribers/logger'
require 'acapi/publishers/logger'

ActiveSupport::Notifications.subscribe "process_action.action_controller" do |name, start, finish, id, payload|
  Rails.logger.debug(["notification:", name, start, finish, id, payload].join(" "))
end

ActiveSupport::Notifications.subscribe "where" do |name, start, finish, id, payload|
  Rails.logger.debug(["notification:", name, start, finish, id, payload].join(" "))
end 

Acapi::Subscribers::Logger.register("acapi.logger")
# Acapi::Subscribers::Logger.register("acapi.edi_event")

Acapi::Publishers::Logger.listen_queue("acapi.logger", "re.logger")
