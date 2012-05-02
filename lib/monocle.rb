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
      cache_view_counts: false
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

    def most_viewed_since(since, limit = 1000)
      objects = self._monocle_redis_connection.zrevrangebyscore(self.monocle_key, Time.now.to_i, since.to_i, limit: [0, limit])
      objects.collect { |o| self.find(o[0]) }
    end
  end

  def view!
    self._monocle_view_types.keys.each do |view_type|
      cache_field = "#{view_type}_views".to_sym
      count = self._monocle_redis_connection.hincrby(self.class.monocle_key(id), self.send("#{view_type}_views_field"), 1)
      if self._monocle_options[:cache_view_counts] && respond_to?(cache_field)
        update_column(cache_field, count) if respond_to?(:update_column)
        set(cache_field, count) if respond_to?(:set)
      end
    end

    self._monocle_redis_connection.zadd(self.class.monocle_key, Time.now.to_i, id)
  end

  def destroy_views
    self._monocle_redis_connection.del(self.class.monocle_key(id))
  end

  autoload :Server, 'monocle/server'
end
