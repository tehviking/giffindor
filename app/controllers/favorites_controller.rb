class FavoritesController < ApplicationController
  respond_to :json

  # GET /favorite
  def show
    set_favorite
    respond_with @favorite, location: nil
  end

  # POST /favorites
  def create
    @favorite = current_user.favorites.create(favorite_params)
    respond_with @favorite, location: nil
  end

  # DELETE /favorites/1
  def destroy
    @favorite = current_user.favorites.find(params[:id])
    @favorite.destroy
    respond_to do |format|
      format.json {render json: {}, status: :ok, location: nil}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_favorite
      @favorite = Favorite.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def favorite_params
      params.delete(:user_id)
      params.require(:favorite).permit(:gif_post_id)
    end
end
