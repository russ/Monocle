require 'active_support/concern'
require 'active_support/core_ext'
require 'redis'

class Time
  def beginning_of_hour
    change(min: 0, sec: 0, usec: 0)
  end
end

module Monocle
  extend ActiveSupport::Concern

  included do
    @@redis = Redis.new || REDIS

    @@view_types = {
      overall: -> { 'overall' },
      yearly: -> { Time.now.beginning_of_year.to_i },
      monthly: -> { Time.now.beginning_of_month.to_i },
      weekly: -> { Time.now.beginning_of_week.to_i },
      daily: -> { Time.now.beginning_of_day.to_i },
      hourly: -> { Time.now.beginning_of_hour.to_i }
    }

    class_eval do
      def monocle_key
        "monocle:#{self.class.to_s.downcase}:#{id}:"
      end
    end

    @@view_types.each do |k,v|
      define_method("#{k}_views_count") do
        @@redis.hget(monocle_key, self.send("#{k}_views_field")).to_i || 0
      end

      define_method("#{k}_views_field") do
        v.call
      end
    end

    if self.respond_to?(:after_destroy)
      after_destroy(:destroy_views)
    else
      warn("#{self} doesn't support after_destroy callback, views will not be cleared automatically when object is destroyed")
    end
  end

  def view!
    @@view_types.keys.each do |view_type|
      count = @@redis.hincrby(self.monocle_key, self.send("#{view_type}_views_field"), 1)
      cache_field = "#{view_type}_views".to_sym
      if respond_to?(cache_field)
        update_column(cache_field, count) if respond_to?(:update_column)
        set(cache_field, count) if respond_to?(:set)
      end
    end
  end

  def destroy_views
    @@redis.del(self.monocle_key)
  end

  autoload :Server, 'monocle/server'
end
