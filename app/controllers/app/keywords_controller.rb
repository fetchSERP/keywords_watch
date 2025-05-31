class App::KeywordsController < App::ApplicationController
  before_action :set_keyword, only: %i[ show edit update destroy ]

  # GET /keywords or /keywords.json
  def index
    @keywords = Current.user.keywords.order(indexed: :desc)
  end

  # GET /keywords/1 or /keywords/1.json
  def show
  end

  # GET /keywords/new
  def new
    @keyword = Current.user.keywords.build
  end

  # GET /keywords/1/edit
  def edit
  end

  # POST /keywords or /keywords.json
  def create
    @keyword = Current.user.keywords.build(keyword_params)

    respond_to do |format|
      if @keyword.save
        format.html { redirect_to [:app, @keyword.domain], notice: "Keyword was successfully created." }
        format.json { render :show, status: :created, location: @keyword }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /keywords/1 or /keywords/1.json
  def update
    respond_to do |format|
      if @keyword.update(keyword_params)
        format.turbo_stream { render turbo_stream: turbo_stream.replace("keyword_#{@keyword.id}", partial: "app/keywords/keyword", locals: { keyword: @keyword }) }
        format.html { redirect_to [:app, @keyword], notice: "Keyword was successfully updated." }
        format.json { render :show, status: :ok, location: @keyword }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @keyword.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /keywords/1 or /keywords/1.json
  def destroy
    @keyword.destroy!

    respond_to do |format|
      format.html { redirect_to app_keywords_path, status: :see_other, notice: "Keyword was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_keyword
      @keyword = Keyword.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def keyword_params
      params.expect(keyword: [ :name, :avg_monthly_searches, :competition, :competition_index, :low_top_of_page_bid_micros, :high_top_of_page_bid_micros, :domain_id, :is_tracked ])
    end
end
