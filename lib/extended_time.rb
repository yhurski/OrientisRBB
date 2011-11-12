require 'time'

class ExtendedTime < Time#WithZone
	def self.dsttime(use_dst = 0)
		if use_dst == 0			
			Time.zone.now
		else
			Time.now.isdst ? Time.zone.now + 1.hour : Time.zone.now
		end
  end
end

