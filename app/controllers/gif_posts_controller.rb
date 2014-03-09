class GifPostsController < ApplicationController
  before_filter :authenticate_user!, except: [:index, :show]
  before_action :set_gif_post, only: [:show, :edit, :update, :destroy]
  respond_to :json, :html
  # GET /gif_posts
  def index
    @gif_posts = GifPost.all
  end

  # GET /gif_posts/1
  def show
    respond_with @gif_post
  end

  # GET /gif_posts/new
  def new
    @gif_post = GifPost.new
  end

  # GET /gif_posts/1/edit
  def edit
  end

  # POST /gif_posts
  def create
    @gif_post = GifPost.create(gif_post_params)
    respond_with @gif_post
  end

  # PATCH/PUT /gif_posts/1
  def update
    if @gif_post.update(gif_post_params)
      respond_with @gif_post
    end
  end

  # DELETE /gif_posts/1
  def destroy
    @gif_post.destroy
    respond_to do |format|
      format.html {redirect_to gif_posts_url}
      format.json {render nothing: true}
    end
  end

  def details
    respond_to do |format|
      format.html { render "ember/index" }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_gif_post
      @gif_post = GifPost.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def gif_post_params
      params.require(:gif_post).permit(:title, :url, :description)
    end
end
