class CharactersController < ApplicationController

  def show
    @character = Character.find(params[:id])
    respond_with @character
  end

end
