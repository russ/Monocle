require 'sinatra/base'

module Monocle
  class Server < Sinatra::Base
    post '/:type/:id(.:format)' do
      if object = params[:type].classify.constantize.find(params[:id])
        object.view!
        'o_0 +1'
      else
        'o_0'
      end
    end
  end
end
