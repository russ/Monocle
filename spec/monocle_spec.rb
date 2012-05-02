require 'spec_helper'

class TestObject
  include Monocle

  attr_accessor :overall_views, :yearly_views, :monthly_views, :weekly_views, :daily_views, :hourly_views

  def initialize
    @overall_views = 0
  end

  def id
    '12345'
  end

  def update_column(field, count)
    self.send("#{field}=", count)
  end

  def after_destroy; end
end

describe Monocle do
  let(:object) { TestObject.new }

  describe 'destroy_views' do
    it 'deletes views for object' do
      object.view!
      object.destroy_views
      REDIS.hget('monocle.testobject:12345', 'overall_views').should == nil
    end
  end

  describe '#view!' do
    before do
      50.times { object.view! }
    end

    after do
      object.destroy_views
    end

    %w(overall yearly monthly weekly daily hourly).each do |view_type|
      it "sets #{view_type} views count" do
        object.send("#{view_type}_views_count").should == 50
      end

      it "updates cached #{view_type} views count" do
        object.send("#{view_type}_views").should == 50
      end
    end
  end
end
