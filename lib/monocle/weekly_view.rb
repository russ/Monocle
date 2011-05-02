module Monocle
  class WeeklyView < View
    validates_presence_of :viewed_on_start_date
  end
end
