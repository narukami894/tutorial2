class UsersController < ApplicationController
  before_action :authenticate_user!,  only: %i[index edit update destroy
                                               following followers]
  before_action :set_user,            only: %i[show edit update following
                                               followers]
  before_action :correct_user,        only: %i[edit update]
  before_action :admin_user,          only: :destroy

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = 'Please check your email to activate your account.'
      redirect_to root_url
    else
      render :new
    end
  end

  def show
    redirect_to root_url and return unless @user.activated?
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def edit; end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = 'Profile updated'
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    user = User.find(params[:id])
    user.delete unless user.admin?
    flash[:success] = 'User deleted'
    redirect_to users_url
  end

  def following
    @title = 'Following'
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = 'Followers'
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def set_user
    @user = User.find(params[:id])
  end

  def correct_user
    redirect_to root_url unless current_user?(@user)
  end

  def user_params
    params.require(:user).permit(:name, :email, :password,
                                 :password_confirmation)
  end
end
