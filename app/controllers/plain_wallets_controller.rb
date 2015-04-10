class PlainWalletsController < ApplicationController
  before_action :set_plain_wallet, only: [:show, :edit, :update]

  # GET /plain_wallet
  # GET /plain_wallet
  def show
    respond_to do |format|
      format.html
      # not using jbuilder
      format.json { render json: @plain_wallet }
    end
  end

  # GET /plain_wallet/edit
  def edit
  end

  # PATCH/PUT /plain_wallet
  # PATCH/PUT /plain_wallet
  def update
    respond_to do |format|
      if @plain_wallet.update(plain_wallet_params)
        format.html { redirect_to plain_wallet_path, notice: 'Your wallet was successfully updated.' }
        format.json { render json: @plain_wallet, status: :ok, location: plain_wallet_path }
      else
        format.html { render :edit }
        format.json { render json: @plain_wallet.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def plain_wallet_params
    params[:plain_wallet].permit(:email, :first_name, :last_name)
  end
end
