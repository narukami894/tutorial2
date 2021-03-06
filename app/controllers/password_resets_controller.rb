class PasswordResetsController < ApplicationController
  before_action :set_user, :check_expiration, :valid_user, only: %i[edit update]

  def new; end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = 'Email sent with password reset instructions'
      redirect_to root_url
    else
      flash[:danger] = 'Email address not found'
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render :edit
    elsif @user.update_attributes(user_params)
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = 'Password has been reset'
      redirect_to @user
    else
      render :edit
    end
  end

  private

  def set_user
    @user = User.find_by(email: params[:email])
  end

  def check_expiration
    if @user && @user.expired?(@user.reset_sent_at, 2.hours.ago)
      flash[:danger] = 'Password reset has expired'
      redirect_to new_password_reset_path
    end
  end

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def valid_user
    redirect_to root_url unless @user && @user.activated? && @user.authenticated?(:reset, params[:id])
  end
end
