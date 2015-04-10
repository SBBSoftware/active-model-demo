class WalletsController < ApplicationController
  before_action :set_wallet, only: [:show, :edit, :update]

  # GET /wallet
  # GET /wallet.json
  def show
  end

  # GET /wallet/edit
  def edit
  end

  # PATCH/PUT /wallet
  # PATCH/PUT /wallet.json
  def update
    respond_to do |format|
      if @wallet.update(wallet_params)
        format.html { redirect_to wallet_path, notice: 'Your wallet was successfully updated.' }
        format.json { render :show, status: :ok, location: @wallet }
      else
        format.html { render :edit }
        format.json { render json: @wallet.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def wallet_params
    params[:wallet].permit(:email, :first_name, :last_name)
  end
end
