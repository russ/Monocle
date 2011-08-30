require "sinatra/base"

module Monocle
  class Server < Sinatra::Base
    post "/:type/:id" do
      begin
        params[:type].classify.constantize.find(params[:id]).view!
        ActiveRecord::Base.clear_active_connections!
        "o_0 +1"
      rescue ActiveRecord::RecordNotFound
        "o_0"
      end
    end

    get "/:type/:id" do
      content_type("image/gif")
      File.open(File.join(File.dirname(__FILE__), "..", "transparent.gif"))
    end
  end
end
