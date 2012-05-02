require 'spec_helper'

class TestObject
  include Monocle

  monocle_options cache_view_counts: true

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
end

describe Monocle do
  let(:object) { TestObject.new }

  describe '#most_viewed_since' do
    before do
      10.times do |i|
        o = TestObject.new
        o.id = i
        (i + 10).times do
          o.view!
        end
      end
    end

    it 'returns top viewed objects since a given time' do
      viewed = TestObject.most_viewed_since(Time.now.beginning_of_day)
      viewed.class.should == Array
      viewed.first.id.should == TestObject.find(9).id
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
