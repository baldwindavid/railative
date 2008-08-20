require 'bilson/railative/time'

#ActiveSupport::CoreExtensions::Time::Calculations.send(:include, Bilson::Railative::Time)

ActionController::Base.helper(Bilson::Railative::Helpers)
