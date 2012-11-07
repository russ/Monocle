require 'sinatra/base'
require 'base64'

module Monocle
  class Server < Sinatra::Base
    post '/:type/:id.:format' do
      view_object(params[:type], params[:id])
    end

    get '/:type/:id.:format' do
      view_object(params[:type], params[:id])
    end

    get '/:type/click/:id.:format' do
      click_object(params[:type], params[:id], params[:redirect_to])
    end

    get '/:type/click/:redirect_to/:id.:format' do
      click_object(params[:type], params[:id], params[:redirect_to])
    end

    def view_object(type, id)
      if object = type.classify.constantize.find(id)
        object.view!
        'o_0 +1'
      else
        'o_0'
      end
    end

    def click_object(type, id, redirect_to)
      if object = type.classify.constantize.find(id)
        object.click!
        redirect(Base64.decode64(redirect_to), 301)
      end
    end
  end
end
