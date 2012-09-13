require 'spec_helper'

class TestObject
  include Monocle

  monocle_options cache_view_counts: true,
                  cache_threshold: 15.minutes,
                  cache_threshold_check_field: :updated_at

  monocle_views overall:   -> { 'overall' },
                yearly:    -> { Time.now.beginning_of_year },
                monthly:   -> { Time.now.beginning_of_month },
                weekly:    -> { Time.now.beginning_of_week },
                daily:     -> { Time.now.beginning_of_day },
                hourly:    -> { Time.now.beginning_of_hour },
                quarterly: -> { Time.now.beginning_of_quarter }

  attr_accessor :id
  attr_accessor :overall_views, :yearly_views, :monthly_views
  attr_accessor :weekly_views, :daily_views, :hourly_views
  attr_accessor :quarterly_views

  def self.find(id)
    o = new
    o.id = id.to_i
    o
  end

  def initialize
    @id = '12345'
    @overall_views = 0
  end

  def update_column(field, count)
    self.send("#{field}=", count)
  end

  def updated_at
    Time.now - 1.hour
  end
end

describe Monocle do
  let(:object) { TestObject.new }

  describe '#recently_viewed' do
    before do
      10.times do |i|
        o = TestObject.new
        o.id = i
        o.view!
      end
    end

    it 'returns the recently viewed objects in reverse order' do
      recently_viewed = TestObject.recently_viewed(10)
      recently_viewed.class.should == Array
      recently_viewed.first.to_i.should == 9
      recently_viewed.last.to_i.should == 0
    end
  end

  describe '#most_viewed_since' do
    before do
      10.times do |i|
        o = TestObject.new
        o.id = i
        o.view!
      end

      10.times { TestObject.find(3).view! }
    end

    it 'returns top viewed objects since a given time' do
      viewed = TestObject.most_viewed_since(Time.now.beginning_of_day)
      viewed.class.should == Array
      viewed.first.to_i.should == 3
    end
  end

  describe '#destroy_views' do
    it 'deletes views for object' do
      object.view!
      object.destroy_views
      REDIS.hget('monocle:test_object:12345', 'overall_views').should == nil
    end
  end

  describe '#view!' do
    before do
      50.times { object.view! }
    end

    after do
      object.destroy_views
    end

    %w(overall yearly monthly weekly daily hourly quarterly).each do |view_type|
      it "sets #{view_type} views count" do
        object.send("#{view_type}_views_count").should == 50
      end

      it "updates cached #{view_type} views count" do
        object.send("#{view_type}_views").should == 50
      end
    end
  end
end
