require 'active_support/concern'
require 'active_support/core_ext'
require 'redis'

require 'monocle/core_ext'

module Monocle
  extend ActiveSupport::Concern

  included do
    class_attribute :_monocle_options,
                    :_monocle_view_types,
                    :_monocle_redis_connection

    self._monocle_options = {
      cache_view_counts: false,
      cache_threshold: 15.minutes,
      cache_threshold_check_field: :updated_at
    }

    self._monocle_view_types = {
      overall: -> { 'overall' },
      yearly:  -> { Time.now.beginning_of_year },
      monthly: -> { Time.now.beginning_of_month },
      weekly:  -> { Time.now.beginning_of_week },
      daily:   -> { Time.now.beginning_of_day },
      hourly:  -> { Time.now.beginning_of_hour }
    }

    self._monocle_redis_connection = Redis.new || REDIS
  end

  module ClassMethods
    def monocle_key(*append)
      extra = (append.empty?) ? '' : ':' + append.join(':')
      "monocle:#{self.to_s.underscore}" + extra
    end

    def monocle_options(options = {})
      self._monocle_options = self._monocle_options.merge(options)
    end

    def monocle_views(types = {})
      self._monocle_view_types = types
      self._monocle_view_types.each do |k,v|
        define_method("#{k}_views_count") do
          self._monocle_redis_connection.hget(self.class.monocle_key(id), self.send("#{k}_views_field")).to_i || 0
        end

        define_method("#{k}_views_field") do
          field = v.call
          field.is_a?(String) ? field : field.to_i
        end
      end
    end

    def recently_viewed(since, limit = 1000)
      self._monocle_redis_connection.zrevrangebyscore(self.monocle_key('recently_viewed'), Time.now.to_i, since.to_i, limit:[0,limit])
    end

    def most_viewed_since(since, limit = 1000)
      self._monocle_redis_connection.zrevrangebyscore(self.monocle_key('view_counts'), '+inf', '-inf', limit: [0, limit]) & recently_viewed(limit)
    end
  end

  def view!
    self._monocle_view_types.keys.each do |view_type|
      count = self._monocle_redis_connection.hincrby(self.class.monocle_key(id), self.send("#{view_type}_views_field"), 1)
      cache_view_count(view_type, count) if should_cache_view_count?(view_type)
    end

    self._monocle_redis_connection.zadd(self.class.monocle_key('recently_viewed'), Time.now.to_i, id)
    self._monocle_redis_connection.zincrby(self.class.monocle_key('view_counts'), 1, id)
  end

  def cache_field_for_view(view_type)
    "#{view_type}_views".to_sym
  end

  def should_cache_view_count?(view_type)
    if self._monocle_options[:cache_view_counts] && respond_to?(cache_field_for_view(view_type))
      if self.send(self._monocle_options[:cache_threshold_check_field]) < (Time.now - self._monocle_options[:cache_threshold])
        return true
      end
    end
    false
  end

  def cache_view_count(view_type, count)
    update_column(cache_field_for_view(view_type), count) if respond_to?(:update_column)
    set(cache_field_for_view(view_type), count) if respond_to?(:set)
  end

  def destroy_views
    self._monocle_redis_connection.del(self.class.monocle_key(id))
  end

  autoload :Server, 'monocle/server'
end
