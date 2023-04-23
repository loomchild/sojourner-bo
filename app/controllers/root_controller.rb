class RootController < ApplicationController
  def index
    redirect_to Conference.root
  end
end
