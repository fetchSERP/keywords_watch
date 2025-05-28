class App::BacklinksController < App::ApplicationController
  before_action :set_backlink, only: %i[ show edit update destroy ]

  # GET /backlinks or /backlinks.json
  def index
    @backlinks = Current.user.backlinks
  end

  # GET /backlinks/1 or /backlinks/1.json
  def show
  end

  # GET /backlinks/new
  def new
    @backlink = Current.user.backlinks.build
  end

  # GET /backlinks/1/edit
  def edit
  end

  # POST /backlinks or /backlinks.json
  def create
    @backlink = Current.user.backlinks.build(backlink_params)

    respond_to do |format|
      if @backlink.save
        format.html { redirect_to [:app, @backlink], notice: "Backlink was successfully created." }
        format.json { render :show, status: :created, location: @backlink }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @backlink.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /backlinks/1 or /backlinks/1.json
  def update
    respond_to do |format|
      if @backlink.update(backlink_params)
        format.html { redirect_to [:app, @backlink], notice: "Backlink was successfully updated." }
        format.json { render :show, status: :ok, location: @backlink }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @backlink.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /backlinks/1 or /backlinks/1.json
  def destroy
    @backlink.destroy!

    respond_to do |format|
      format.html { redirect_to app_backlinks_path, status: :see_other, notice: "Backlink was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_backlink
      @backlink = Backlink.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def backlink_params
      params.expect(backlink: [ :user_id, :domain_id, :source_url, :target_url, :anchor_text, :nofollow, :rel_attributes, :context_text, :source_domain, :target_domain, :page_title, :meta_description ])
    end
end
