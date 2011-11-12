class Moderator < ActiveRecord::Base
  belongs_to :subpartition
  belongs_to :user, :foreign_key => 'moderator_id'
end
