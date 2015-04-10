class PlainCardsController < ApplicationController
  # before_action :set_plain_card, only: [:show, :update, :destroy]
  before_action :set_plain_wallet, only: [:edit, :create, :update, :destroy]

  # GET /plain_wallet/plain_cards/new
  def new
    @plain_card = PlainCard.new
  end

  # GET /plain_wallet/plain_cards/1/edit
  def edit
    @plain_card = @plain_wallet.find_plain_card(plain_card_id)
  end

  # POST /plain_wallet/plain_cards
  # POST /plain_wallet/plain_cards.json
  def create
    @plain_card = PlainCard.new(plain_card_params)
    # todo violation add card method to plain_wallet
    @plain_wallet.cards << @plain_card
    respond_to do |format|
      if @plain_wallet.save
        format.html { redirect_to plain_wallet_path, notice: 'Card was successfully created.' }
        format.json { render json: @plain_wallet, status: :ok, location: plain_wallet_path }
      else
        format.html { render :new }
        format.json { render json: @plain_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /plain_wallet/plain_cards/1
  # PATCH/PUT /plain_wallet/plain_cards/1.json
  def update
    respond_to do |format|
      if @plain_wallet.update_plain_card(plain_card_id, plain_card_params)
        format.html { redirect_to plain_wallet_path, notice: 'Card was successfully updated.' }
        format.json { render json: @plain_wallet, status: :ok, location: plain_wallet_path }
      else
        @plain_card = @plain_wallet.find_plain_card(plain_card_id)
        format.html { render :edit }
        format.json { render json: @plain_card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /plain_wallet/plain_cards/1
  # DELETE /plain_wallet/plain_cards/1.json
  def destroy
    respond_to do |format|
      @plain_wallet.destroy_plain_card(plain_card_id)
      format.html { redirect_to plain_wallet_path, notice: 'Card was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  private

  # array index begins with 0
  # id on views begins with 1
  # translate view index to array index
  def plain_card_id
    params[:id].to_i - 1
  end

  def plain_card_params
    params[:plain_card].permit(:card_number, :expiration_date, :card_type, :id)
  end
end
