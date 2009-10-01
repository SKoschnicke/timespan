class TimeOfDay

  include Comparable

  attr_accessor :hour, :minute

  def initialize(hour, minute)
    raise ArgumentError.new "hour should not be nil." if hour.nil?
    raise ArgumentError.new "minute should not be nil." if minute.nil?
    raise ArgumentError.new "hour needs to be an integer, got #{hour.inspect} which is of type #{minute.class}" unless hour.kind_of? Numeric
    raise ArgumentError.new "minute needs to be an integer, got #{minute.inspect} which is of type #{minute.class}" unless minute.kind_of? Numeric
    raise ArgumentError.new "hour needs to be between 0 and 23, got #{hour}" unless hour.between? 0, 23
    raise ArgumentError.new "minute needs to be between 0 and 59, got #{minute}" unless minute.between? 0, 59
    hour = 0 if hour.nil?
    minute = 0 if minute.nil?

    @hour = hour
    @minute = minute
  end

  def <=>(other)
    if other.kind_of? TimeOfDay
      compare_to(other.hour, other.minute)
    elsif other.kind_of? Time or other.kind_of? DateTime
      compare_to(other.hour, other.min)
    else
      raise ArgumentError.new "object to compare to must be kind of TimeOfDay, Time or DateTime, was #{other.class}"
    end
  end

  def compare_to(hour, minute)
    if @hour == hour
      @minute <=> minute
    else
      @hour <=> hour
    end
  end

  def to_minutes
    @hour * 60 + @minute
  end

  def -(other)
    if other.instance_of? TimeOfDay
      raise ArgumentError.new "can't subtract a later time (#{other}) from #{self}'" if other > self
      self.to_minutes - other.to_minutes
    elsif other.kind_of? Numeric
      TimeOfDay.from_minutes(self.to_minutes - other)
    else
      raise ArgumentError.new "expected an instance of TimeOfDay, got #{other.inspect}"
    end
  end

  def +(other)
    if other.kind_of? Numeric
      raise ArgumentError.new "can't add #{other} minutes to #{self} because it would result in a time on the next day" if self.to_minutes > (24 * 60 - other)
      TimeOfDay.from_minutes(self.to_minutes + other)
    else
      raise ArgumentError.new "expected kind of Numeric, got #{other.inspect}"
    end
  end

  # returns a new time with the date from the given time and the time from itself
  def set(time)
    utc_time = time.utc
    Time.utc(utc_time.year, utc_time.month, utc_time.day, @hour, @minute, utc_time.sec).in_time_zone
  end

  def to_s
    # 'implicit' conversion to local timezone
    set(Time.zone.now).strftime("%H:%M")
  end

  def self.from_string(string)
    hour_string, minute_string = string.split(":")
    minutes = hour_string.to_i * 60 + minute_string.to_i - (Time.zone.now.utc_offset / 60)
    if minutes < 0
      minutes += 24*60
    end
    TimeOfDay.from_minutes(minutes >= (24*60) ? minutes.div(24*60) : minutes)
  end

  def self.parse(string)
    from_string(string)
  end

  def self.from_minutes(minutes)
    new(minutes.div(60), minutes.modulo(60))
  end

end
