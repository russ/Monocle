class Time
  def beginning_of_hour
    change(min: 0, sec: 0, usec: 0)
  end
end
