class Censor < ActiveRecord::Base
  validates_presence_of :source_word
  validates_presence_of :dest_word
  validates_length_of :source_word, :maximum => 60
  validates_length_of :dest_word,     :maximum => 60

  #replace censoring words
  #see administration - features and administration - censoring
  def self.censoring(message)
    return message if self.all.blank?
    for source_dest_pair in self.all
      message.gsub!(/#{source_dest_pair.source_word}/i, source_dest_pair.dest_word)
    end
    message
  end
end
