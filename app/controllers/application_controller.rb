class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include AdminActivitiesHelper
  include AdminsessionsHelper
  include StudentsessionsHelper
  include LecturersessionsHelper
  include RegistrationsHelper
  include ApplicationHelper
  include LoginSessionsHelper
end
