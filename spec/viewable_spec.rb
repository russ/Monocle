require "spec_helper"

class Viewable < ActiveRecord::Base
  include Monocle::Views
end

describe Viewable do
  subject { Viewable.new }

  it { should have_one(:overall_view) }
  it { should have_many(:daily_views) }
  it { should have_many(:weekly_views) }
  it { should have_many(:monthly_views) }
  it { should have_many(:yearly_views) }

  describe "view!" do
    before do
      subject.save!
    end

    it "should increment overall view count" do
      subject.view!
      subject.overall_views.should == 1
    end

    %w( daily weekly monthly yearly ).each do |time_span|
      it "should increment #{time_span} view count" do
        5.times do |i|
          view = "#{time_span}_views"
          subject.view!
          subject.send(view).first.views.should == i + 1
        end
      end
    end
  end
end
