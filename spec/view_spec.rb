require "spec_helper"

include Monocle

describe View do
  describe "since" do
    before do
      50.times do |i|
        create_view(
          :viewable_id => i,
          :viewed_on_start_date => Time.now - i.days,
          :views => rand(100))
      end
    end

    # TODO: Find a decent way to test this.
    it "returns most viewed objects since the given date" do
      View.since(7.days).all.count.should == 8
    end
  end

  describe "all_time" do
    before do
      50.times do |i|
        create_view(
          :viewable_id => i,
          :viewed_on_start_date => Time.now - i.days,
          :views => rand(100))
      end
    end

    it "returns most viewed objects of all time" do
      View.all_time.all.count.should == 10
    end
  end
end
