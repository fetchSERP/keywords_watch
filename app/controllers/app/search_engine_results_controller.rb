class App::SearchEngineResultsController < App::ApplicationController
  before_action :set_search_engine_result, only: %i[ show edit update destroy ]

  # GET /search_engine_results or /search_engine_results.json
  def index
    @search_engine_results = SearchEngineResult.all
  end

  # GET /search_engine_results/1 or /search_engine_results/1.json
  def show
  end

  # GET /search_engine_results/new
  def new
    @search_engine_result = SearchEngineResult.new
  end

  # GET /search_engine_results/1/edit
  def edit
  end

  # POST /search_engine_results or /search_engine_results.json
  def create
    @search_engine_result = SearchEngineResult.new(search_engine_result_params)

    respond_to do |format|
      if @search_engine_result.save
        format.html { redirect_to @search_engine_result, notice: "Search engine result was successfully created." }
        format.json { render :show, status: :created, location: @search_engine_result }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @search_engine_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /search_engine_results/1 or /search_engine_results/1.json
  def update
    respond_to do |format|
      if @search_engine_result.update(search_engine_result_params)
        format.html { redirect_to @search_engine_result, notice: "Search engine result was successfully updated." }
        format.json { render :show, status: :ok, location: @search_engine_result }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @search_engine_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /search_engine_results/1 or /search_engine_results/1.json
  def destroy
    @search_engine_result.destroy!

    respond_to do |format|
      format.html { redirect_to search_engine_results_path, status: :see_other, notice: "Search engine result was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_search_engine_result
      @search_engine_result = SearchEngineResult.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def search_engine_result_params
      params.expect(search_engine_result: [ :user_id, :keyword_id, :site_name, :url, :title, :description, :ranking ])
    end
end
