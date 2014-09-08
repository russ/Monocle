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

    self._monocle_redis_connection = $redis || REDIS || Redis.new
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

        define_method("#{k}_clicks_count") do
          self._monocle_redis_connection.hget(self.class.monocle_key(id), self.send("#{k}_clicks_field")).to_i || 0
        end

        define_method("#{k}_clicks_field") do
          field = v.call
          field.is_a?(String) ? field : field.to_i
        end
      end
    end

    def recently_viewed_since(since, options = {})
      options[:limit] ||= 1000
      options[:with_objects] = options.has_key?(:with_objects) ? options[:with_objects] : true

      results = self._monocle_redis_connection.zrevrangebyscore(self.monocle_key('recently_viewed'), Time.now.to_i, since.to_i, limit:[0, options[:limit]])
      options[:with_objects] ? results.map { |id| self.find(id) } : results
    end

    def most_viewed_since(since, options = {})
      options[:limit] ||= 1000
      options[:with_objects] = options.has_key?(:with_objects) ? options[:with_objects] : true

      viewed_by_score = self._monocle_redis_connection.zrevrangebyscore(self.monocle_key('view_counts'), '+inf', '-inf', limit: [0, options[:limit]])
      results = viewed_by_score & recently_viewed_since(since, with_objects: false, limit: options[:limit])
      options[:with_objects] ? results.map { |id| self.find(id) } : results
    end
  end

  def view!
    results = self._monocle_redis_connection.pipelined do
      self._monocle_view_types.keys.each do |view_type|
        self._monocle_redis_connection.hincrby(self.class.monocle_key(id), self.send("#{view_type}_views_field"), 1)
      end
      self._monocle_redis_connection.zadd(self.class.monocle_key('recently_viewed'), Time.now.to_i, id)
      self._monocle_redis_connection.zincrby(self.class.monocle_key('view_counts'), 1, id)
    end

    if should_cache_view_count?
      self._monocle_view_types.keys.each_with_index do |view_type, i|
        cache_view_count(view_type, results[i])
      end
      self.update_column(self._monocle_options[:cache_threshold_check_field].to_sym, Time.now) if respond_to?(:update_column)
      self.set(self._monocle_options[:cache_threshold_check_field].to_sym, Time.now) if respond_to?(:set)
    end
  end

  def click!
    results = self._monocle_redis_connection.pipelined do
      self._monocle_view_types.keys.each do |view_type|
        self._monocle_redis_connection.hincrby(self.class.monocle_key(id), self.send("#{view_type}_clicks_field"), 1)
      end
      self._monocle_redis_connection.zadd(self.class.monocle_key('recently_clicked'), Time.now.to_i, id)
      self._monocle_redis_connection.zincrby(self.class.monocle_key('click_counts'), 1, id)
    end

    if should_cache_view_count?
      self._monocle_view_types.keys.each_with_index do |view_type, i|
        cache_click_count(view_type, results[i])
      end
      self.update_column(self._monocle_options[:cache_threshold_check_field].to_sym, Time.now) if respond_to?(:update_column)
      self.set(self._monocle_options[:cache_threshold_check_field].to_sym, Time.now) if respond_to?(:set)
    end
  end

  def cache_field_for_view(view_type)
    :"#{view_type}_views"
  end

  def cache_field_for_click(view_type)
    :"#{view_type}_clicks"
  end

  def should_cache_view_count?
    if self._monocle_options[:cache_view_counts]
      self.send(self._monocle_options[:cache_threshold_check_field]) < (Time.now - self._monocle_options[:cache_threshold])
    else
      false
    end
  end

  def cache_view_count(view_type, count)
    update_column(cache_field_for_view(view_type), count) if respond_to?(:update_column)
    set(cache_field_for_view(view_type), count) if respond_to?(:set)
  end

  def cache_click_count(view_type, count)
    update_column(cache_field_for_click(view_type), count) if respond_to?(:update_column)
    set(cache_field_for_click(view_type), count) if respond_to?(:set)
  end

  def destroy_views
    self._monocle_redis_connection.del(self.class.monocle_key(id))
  end

  autoload :Server, 'monocle/server'
end
