class TimeSpan < ActiveRecord::Base

  composed_of :starttime,
              :class_name => "TimeOfDay",
              :mapping =>
                [ # database        ruby
                  %w[ start_hour     hour ],
                  %w[ start_minute   minute ]
                ],
              :allow_nil => false,
              :constructor => Proc.new {|hour, minute| TimeOfDay.new((hour.nil? ? 0 : hour.to_i), (minute.nil? ? 0 : minute.to_i))},
              :converter => Proc.new {|value| TimeOfDay.parse(value)}

  composed_of :endtime,
              :class_name => "TimeOfDay",
              :mapping =>
                [ # database        ruby
                  %w[ end_hour     hour ],
                  %w[ end_minute   minute ]
                ],
              :allow_nil => false,
              :constructor => Proc.new {|hour, minute| TimeOfDay.new((hour.nil? ? 0 : hour.to_i), (minute.nil? ? 0 : minute.to_i))},
              :converter => Proc.new {|value| TimeOfDay.parse(value)}

  composed_of :weekdays,
              :class_name => "WeekdaySelection",
              :mapping =>
                [ # database        ruby
                  %w[ on_monday     monday ],
                  %w[ on_tuesday    tuesday ],
                  %w[ on_wednesday  wednesday ],
                  %w[ on_thursday   thursday ],
                  %w[ on_friday     friday ],
                  %w[ on_saturday   saturday ],
                  %w[ on_sunday     sunday]
                ]
             # ,:constructor => Proc.new {|mon,tue,wed,thu,fri,sat,sun| WeekdaySelection.new(true, true, true, true, true, false, false) }

  validate :starttime_is_before_endtime


  def include?(datetime)
    is_on_weekday_of(datetime) and starttime.set(datetime) <= datetime and endtime.set(datetime) >= datetime
  end

  def is_on_weekday_of(datetime)
    weekdays.include?(WeekdaySelection.symbol_from_numeric_weekday(datetime.wday))
  end

  protected

    def starttime_is_before_endtime
      errors.add("starttime (#{starttime.inspect}) has to be before endtime (#{endtime.inspect})") unless (daily or starttime < endtime)
    end

    def next_day(datetime)
      next_datetime = datetime.clone
      begin
        next_datetime += 1.day
      end while !is_on_weekday_of(next_datetime)
      return next_datetime
    end

    def next_datetime_after(datetime)
      if is_on_weekday_of(datetime)
        if (endtime.set(datetime) >= datetime + 1.minute)
          return datetime + 1.minute
        else
          return starttime.set(next_day(datetime))
        end
      else
        return starttime.set(next_day(datetime))
      end
    end

end
