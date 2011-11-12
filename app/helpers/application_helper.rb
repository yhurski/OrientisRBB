module ApplicationHelper
  def universal_timedate_convert(time_with_zone, format_datetime=true)
    return nil unless time_with_zone.kind_of? Time
    time = time_with_zone.in_time_zone(Configs.get_config('default_timezone') || 'UTC')
    if Configs.get_config('dst').to_i == 0
      time = time.isdst ? time - 1.hour : time
    end
    if format_datetime
      format_datetime time
    end
  end

  def format_datetime value
    date_format = Configs.get_config('default_dateformat') || '%Y-%m-%d'
    time_format = Configs.get_config('default_timeformat') || '%H:%M:%S'
    value.strftime(date_format + " " + time_format)
  end
end
