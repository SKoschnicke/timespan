class WeekdaySelection

  WEEKDAYS = %w[ monday tuesday wednesday thursday friday saturday sunday ]

  attr_reader :monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday

  # note that the initialize method needs to accept the arguments as implemented
  # here or else it can't be used with composed_of (unless setting the constructor option there)
  def initialize(monday = false, tuesday = false, wednesday = false, thursday = false, friday = false, saturday = false, sunday = false)
    @monday = monday.nil? ? false : monday
    @tuesday = tuesday.nil? ? false : tuesday
    @wednesday = wednesday.nil? ? false : wednesday
    @thursday = thursday.nil? ? false : thursday
    @friday = friday.nil? ? false : friday
    @saturday = saturday.nil? ? false : saturday
    @sunday = sunday.nil? ? false : sunday
  end

  def set_as_array(array_of_symbol_weekdays)
    WEEKDAYS.each do |day|
      instance_variable_set("@"+day.to_s, array_of_symbol_weekdays.include?(day.to_sym))
    end
  end

  def get_as_array
    WEEKDAYS.map{|day| day.to_sym if instance_variable_get("@"+day)}.compact
  end

  alias :to_a :get_as_array
  alias :selection :get_as_array
  alias :selection= :set_as_array

  def add(weekday)
    raise_if_not_weekday weekday
    set_as_array(get_as_array() + [ weekday.to_sym ])
  end

  def delete(weekday)
    raise_if_not_weekday weekday_as_symbol
    set_as_array(get_as_array() - [ weekday.to_sym ])
  end

  def include?(weekday)
    raise_if_not_weekday weekday
    get_as_array.include? weekday.to_sym
  end

  def self.symbol_from_numeric_weekday(weekday_number)
    WEEKDAYS[(6 + weekday_number).modulo(7)].to_sym
  end

  protected

    def raise_if_not_weekday(weekday)
      if !WEEKDAYS.include?(weekday.to_s)
        raise ArgumentError.new "Unknown weekday: "+weekday_as_symbol.to_s
      end
    end

end
