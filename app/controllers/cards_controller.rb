class CardsController < ApplicationController
  before_action :set_card, only: [:edit, :update, :destroy]
  


  

  # GET /cards
  # GET /cards.json
  def index
    @cards = Card.all
  end

  # GET /cards/1
  # GET /cards/1.json
  def show

  end


  def negative
    @title = "Negative Spreads"
    @cards = Card.joins(:price).where("spread < ?", 0).where(hidden: false).order('Prices.spread')
    if not params[:foil].nil?
      @cards = @cards.where(is_foil: params[:foil]).order('Prices.spread')
    end
  end

  def low
    @title = "Low Spreads"
    @cards = Card.joins(:price).where("spread <= ?", 20).where("spread >= ?", 0).order('Prices.spread')
    if not params[:foil].nil?
      @cards = @cards.where(is_foil: params[:foil]).order('Prices.spread')
    end
  end

  def standard
     @title = "Low Spreads in Standard"
     get_standard
     @cards = Card.joins(:price).joins(:card_set).where("spread >= ?", 0).where("spread < ?", 21).where('code IN (?)', @standrd_arr).order('Prices.spread')
     if not params[:foil].nil?
      @cards = @cards.where(is_foil: params[:foil]).order('Prices.spread')
    end
  end

  def search
    if params[:q] != "" && params[:q].present?
        @cards = Card.joins(:price).where('prices.spread IS NOT NULL').where('lower(name) like ?', "%#{params[:q].downcase}%").order('Prices.spread')
    else
        @cards = Card.joins(:price).where('prices.spread IS NOT NULL').where(card_set_id: params[:set]).order('Prices.spread')
    end
    if not params[:foil].nil?
      @cards = @cards.where(is_foil: params[:foil]).order('Prices.spread')
    end   
  end

  # GET /cards/new
  def new
    @card = Card.new
  end

  # GET /cards/1/edit
  def edit
  end

  # POST /cards
  # POST /cards.json
  def create
    @card = Card.new(card_params)

    respond_to do |format|
      if @card.save
        format.html { redirect_to @card, notice: 'Card was successfully created.' }
        format.json { render :show, status: :created, location: @card }
      else
        format.html { render :new }
        format.json { render json: @card.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cards/1
  # PATCH/PUT /cards/1.json
  def update
    respond_to do |format|
      if @card.update(card_params)
        format.html { redirect_to @card, notice: 'Card was successfully updated.' }
        format.json { render :show, status: :ok, location: @card }
      else
        format.html { render :edit }
        format.json { render json: @card.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cards/1
  # DELETE /cards/1.json
  def destroy
    @card.destroy
    respond_to do |format|
      format.html { redirect_to cards_url, notice: 'Card was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_card
      @card = Card.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def card_params
      params.require(:card).permit(:name, :tcg_id)
    end
end
