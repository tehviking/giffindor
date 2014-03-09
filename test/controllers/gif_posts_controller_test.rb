require 'test_helper'

class GifPostsControllerTest < ActionController::TestCase
  setup do
    @gif_post = gif_posts(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:gif_posts)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create gif_post" do
    assert_difference('GifPost.count') do
      post :create, gif_post: { body: @gif_post.body, url: @gif_post.url, user_id: @gif_post.user_id }
    end

    assert_redirected_to gif_post_path(assigns(:gif_post))
  end

  test "should show gif_post" do
    get :show, id: @gif_post
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @gif_post
    assert_response :success
  end

  test "should update gif_post" do
    patch :update, id: @gif_post, gif_post: { body: @gif_post.body, url: @gif_post.url, user_id: @gif_post.user_id }
    assert_redirected_to gif_post_path(assigns(:gif_post))
  end

  test "should destroy gif_post" do
    assert_difference('GifPost.count', -1) do
      delete :destroy, id: @gif_post
    end

    assert_redirected_to gif_posts_path
  end
end
