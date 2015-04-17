class DocumentController < ApplicationController
  protect_from_forgery with: :exception
  
  layout "policy"
  
  def policy
  end
  
end
