module Monocle
  class View
  end

  # class View < ActiveRecord::Base
	#   belongs_to :viewable, :polymorphic => true

	#   validates_presence_of :viewable_id
	#   validates_presence_of :viewable_type

	#   def self.by_type(type)
	#     where(:type => type)
  #   end

  #   def self.since(since, options = {})
  #     options[:limit] ||= 10
  #     options[:order] ||= "SUM(views) DESC"
  #     options[:type] ||= :yearly

  #     by_type("Monocle::" + options[:type].to_s.classify + "View")
  #     .where("viewed_on_start_date >= ?", Date.today - since)
  #     .group("viewable_type, viewable_id")
  #     .order(options[:order])
  #     .limit(options[:limit])
  #   end

  #   def self.all_time(options = {})
  #     options[:limit] ||= 10
  #     options[:order] ||= "views DESC"

  #     by_type("Monocle::OverallView")
  #     .group("viewable_type, viewable_id")
  #     .order(options[:order])
  #     .limit(options[:limit])
  #   end

  #   def view!
  #     increment!(:views)
  #   end
  # end
end
