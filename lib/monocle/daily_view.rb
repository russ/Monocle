module Monocle
  class DailyView < View
    validates_presence_of :viewed_on_start_date

    def view!
      %w( Weekly Monthly Yearly Overall ).each do |time_span|
        klass = "Monocle::#{time_span}View".constantize
        start_date = nil

        unless time_span == "Overall"
          time_span.downcase!.gsub!("ly", "")
          start_date = viewed_on_start_date.send("beginning_of_#{time_span}")
        end

        view = klass.find_or_create_by_viewable_type_and_viewable_id_and_viewed_on_start_date(viewable_type, viewable_id, start_date)
        view.view!
      end

      super
    end
  end
end
