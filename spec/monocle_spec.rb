require 'spec_helper'

class TestObject
  include Monocle

  monocle_options cache_view_counts: true,
                  cache_threshold: 15.minutes,
                  cache_threshold_check_field: :updated_at

  monocle_views overall:   -> { 'overall' },
                yearly:    -> { Time.now.beginning_of_year },
                quarterly: -> { Time.now.beginning_of_quarter },
                monthly:   -> { Time.now.beginning_of_month },
                weekly:    -> { Time.now.beginning_of_week },
                daily:     -> { Time.now.beginning_of_day },
                hourly:    -> { Time.now.beginning_of_hour }

  attr_accessor :id
  attr_accessor :updated_at
  attr_accessor :overall_views, :yearly_views, :monthly_views
  attr_accessor :weekly_views, :daily_views, :hourly_views
  attr_accessor :quarterly_views

  attr_accessor :overall_clicks, :yearly_clicks, :monthly_clicks
  attr_accessor :weekly_clicks, :daily_clicks, :hourly_clicks
  attr_accessor :quarterly_clicks

  def self.find(id)
    o = new
    o.id = id.to_i
    o
  end

  def initialize
    @id = '12345'
    @overall_views, @overall_clicks = 0
    @updated_at = Time.now - 1.hour
  end

  def update_column(field, count)
    self.send("#{field}=", count)
  end
end

def make_viewed_objects(number_of_objects_to_make)
  number_of_objects_to_make.times do |i|
    o = TestObject.new
    o.id = i
    o.view!
    o.click!
  end
end

describe Monocle do

  let(:object) { TestObject.new }

  describe '#recently_viewed' do
    before { make_viewed_objects(10) }
    let(:recently_viewed) { TestObject.recently_viewed_since(1.day.ago) }

    it 'returns the most recently viewed object at the top of the list' do
      recently_viewed.first.id.should == 9
    end

    it 'returns the last recently viewed object at the bottom of the list' do
      recently_viewed.last.id.should == 0
    end
  end

  describe '#most_viewed_since' do
    before do
      make_viewed_objects(10)
      10.times { TestObject.find(3).view! }
    end

    it 'returns top viewed objects since a given time' do
      viewed = TestObject.most_viewed_since(Time.now.beginning_of_day)
      viewed.class.should == Array
      viewed.first.id.should == 3
    end
  end

  describe '#destroy_views' do
    it 'deletes views for object' do
      object.view!
      object.destroy_views
      REDIS.hget('monocle:test_object:12345', 'overall_views').should == nil
      REDIS.hget('monocle:test_object:12345', 'overall_clicks').should == nil
    end
  end

  describe '#cache_field_for_view' do
    it 'returns the cache field for the given view type' do
      object.cache_field_for_view('overall').should == :overall_views
      object.cache_field_for_click('overall').should == :overall_clicks
    end
  end

  describe '#should_cache_view_count?' do
    context 'the class has cache_view_counts set to true' do
      context 'the objects last updated time is greater than the threshold' do
        it 'returns true' do
          object.should_cache_view_count?.should == true
        end
      end

      context 'the objects last updated time is less than the threshold' do
        it 'returns true' do
          object.stub(:updated_at).and_return(Time.now)
          object.should_cache_view_count?.should == false
        end
      end
    end

    context 'the class has cache_view_counts set to false' do
      it 'returns false' do
        object.class.stub(:_monocle_options).and_return({cache_view_counts:false})
        object.should_cache_view_count?.should == false
      end
    end
  end

  context 'when cache time is over threshold' do
    describe '#view!' do
      before { object.stub(:updated_at).and_return(Time.now - 1.hour) }
      before { 50.times { object.view!; object.click! }}
      after { object.destroy_views }

      %w(overall yearly monthly weekly daily hourly quarterly).each do |view_type|
        it "sets #{view_type} views count" do
          object.send("#{view_type}_views_count").should == 50
          object.send("#{view_type}_clicks_count").should == 50
        end

        it "updates cached #{view_type} views count" do
          object.send("#{view_type}_views").should == 50
          object.send("#{view_type}_clicks").should == 50
        end
      end
    end
  end

  context 'when cache time is under threshold' do
    describe '#view!' do
      before { object.stub(:updated_at).and_return(Time.now) }
      before { 50.times { object.view! }}
      after { object.destroy_views }

      %w(overall yearly monthly weekly daily hourly quarterly).each do |view_type|
        it "sets #{view_type} views count" do
          object.send("#{view_type}_views_count").should == 50
        end

        it "updates cached #{view_type} views count" do
          object.send("#{view_type}_views").to_i.should == 0
        end
      end
    end

    describe '#click!' do
      before { object.stub(:updated_at).and_return(Time.now) }
      before { 50.times { object.click! }}
      after { object.destroy_views }

      %w(overall yearly monthly weekly daily hourly quarterly).each do |view_type|
        it "sets #{view_type} views count" do
          object.send("#{view_type}_clicks_count").should == 50
        end

        it "updates cached #{view_type} views count" do
          object.send("#{view_type}_clicks").to_i.should == 0
        end
      end
    end
  end
end
