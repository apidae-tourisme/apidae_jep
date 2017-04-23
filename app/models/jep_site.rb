class JepSite < ActiveRecord::Base
  store :site_data, accessors: [:ages], coder: JSON
end
