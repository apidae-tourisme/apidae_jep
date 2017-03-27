class Program < ActiveRecord::Base
  has_many :program_items
  has_and_belongs_to_many :users

end
