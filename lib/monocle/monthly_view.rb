module Monocle
  class MonthlyView < View
    validates_presence_of :viewed_on_start_date
  end
end
