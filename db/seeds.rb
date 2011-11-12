# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)
require "simple-password-gen"

require RAILS_ROOT + '/db/orientis_seeds/configs'
require RAILS_ROOT + '/db/orientis_seeds/groups'
require RAILS_ROOT + '/db/orientis_seeds/users'
require RAILS_ROOT + '/db/orientis_seeds/partitions'
require RAILS_ROOT + '/db/orientis_seeds/subpartitions'
require RAILS_ROOT + '/db/orientis_seeds/topics'
require RAILS_ROOT + '/db/orientis_seeds/posts'
require RAILS_ROOT + '/db/orientis_seeds/forum_perms'

 

