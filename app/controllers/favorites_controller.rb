class FavoritesController < ApplicationController
  before_action :require_user_logged_in
  
  def create
    post = Micropost.find(params[:micropost_id])
    current_user.favorite(post)
    flash[:success] = '投稿をお気に入り登録しました。'
    redirect_to root_url
  end

  def destroy
    post = Micropost.find(params[:micropost_id])
    current_user.unfavorite(post)
    flash[:success] = '投稿をお気に入りから削除しました。'
    redirect_to root_url
  end
end
