require 'sinatra/base'

module Monocle
  class Server < Sinatra::Base
    post '/:type/:id.:format' do
      view_object(params[:type], params[:id])
    end

    get '/:type/:id.:format' do
      view_object(params[:type], params[:id])
    end

    def view_object(type, id)
      if object = type.classify.constantize.find(id)
        object.view!
        'o_0 +1'
      else
        'o_0'
      end
    end
  end
end
