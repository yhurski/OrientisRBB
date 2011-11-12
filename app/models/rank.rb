class Rank < ActiveRecord::Base
  validates_presence_of :rank
  validates_presence_of :num_of_posts
  validates_numericality_of :num_of_posts,  :only_integer => true
  validates_uniqueness_of :num_of_posts, :scope => :num_of_posts
end