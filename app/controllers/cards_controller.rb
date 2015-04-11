class CardsController < ApplicationController
  before_action :set_wallet

  # GET /wallet/cards/new
  def new
    @card = Card.new
  end

  # GET /wallet/cards/1/edit
  def edit
    @card = @wallet.find_card(params[:id])
  end

  # POST /wallet/cards
  # POST /wallet/cards.json
  def create
    @card = Card.new(card_params)
    # todo violation
    @wallet.cards << @card
    respond_to do |format|
      if @wallet.save
        format.html { redirect_to wallet_path, notice: 'Card was successfully created.' }
        format.json { render json: @wallet, status: :ok, location: wallet_path }
      else
        format.html { render :new }
        format.json { render json: @card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wallet/cards/1
  # PATCH/PUT /wallet/cards/1.json
  def update
    respond_to do |format|
      if @wallet.update_card(params[:id], card_params)
        format.html { redirect_to wallet_path, notice: 'Card was successfully updated.' }
        format.json { render json: @wallet, status: :ok, location: wallet_path }
      else
        @card = @wallet.find_card(params[:id])
        format.html { render :edit }
        format.json { render json: @card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wallet/cards/1
  # DELETE /wallet/cards/1.json
  def destroy
    @wallet.destroy_card(params[:id])
    respond_to do |format|
      format.html { redirect_to wallet_path, notice: 'Card was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def card_params
    # todo change to require
    params[:card].permit(:card_number, :expiration_date, :card_type, :short_expiration)
  end
end
