module Monocle
  module Views
    extend ActiveSupport::Concern

    included do
      has_one :overall_view, :as => :viewable, :dependent => :destroy, :class_name => "Monocle::OverallView"

      %w( daily weekly monthly yearly ).each do |time_span|
        has_many "#{time_span}_views".to_sym, :as => :viewable, :dependent => :destroy, :class_name => "Monocle::#{time_span.classify}View"
      end
    end

    module ClassMethods
      def viewed_since(since, options = {})
        View.since(since, { :viewable_type => self }.merge(options))
      end
    end

    delegate :views, :to => :overall_view, :prefix => :overall, :allow_nil => true

    def view!
      view = DailyView.find_or_create_by_viewable_type_and_viewable_id_and_viewed_on_start_date(self.class.name, id, Date.today)
      view.view!
    end
  end
end
