require 'sinatra/base'
require 'base64'
require 'uri'

module Monocle
  class Server < Sinatra::Base
    post '/:type/:id.:format' do
      view_object(params[:type], params[:id])
    end

    get '/:type/:id.gif' do
      view_object(params[:type], params[:id])
      content_type('image/gif')
      Base64.decode64('R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw==')
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
        redirect(Base64.decode64(URI.unescape(redirect_to)), 301)
      end
    end
  end
end
