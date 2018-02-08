class ApplicationController < ActionController::Base
  protect_from_forgery prepend: true, with: :exception
  require 'csv'
  include AdminActivitiesHelper
  include AdminsessionsHelper
  include StudentsessionsHelper
  include LecturersessionsHelper
  include RegistrationsHelper
  include ApplicationHelper
  include LoginSessionsHelper
end
