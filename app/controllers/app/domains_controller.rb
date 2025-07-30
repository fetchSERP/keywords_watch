class App::DomainsController < App::ApplicationController
  before_action :set_domain, only: %i[ show edit update destroy ]

  # GET /domains or /domains.json
  def index
    @domains = Current.user.domains
  end

  # GET /domains/1 or /domains/1.json
  def show
  end

  # GET /domains/new
  def new
    @domain = Current.user.domains.build
  end

  # GET /domains/1/edit
  def edit
  end

  # POST /domains or /domains.json
  def create
    @domain = Current.user.domains.build(domain_params)

    respond_to do |format|
      if @domain.save
        format.html { redirect_to [:app, @domain], notice: "Domain was successfully created." }
        format.json { render :show, status: :created, location: [:app, @domain] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /domains/1 or /domains/1.json
  def update
    respond_to do |format|
      if @domain.update(domain_params)
        format.html { redirect_to @domain, notice: "Domain was successfully updated." }
        format.json { render :show, status: :ok, location: @domain }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /domains/1 or /domains/1.json
  def destroy
    @domain.destroy!

    respond_to do |format|
      format.html { redirect_to app_domains_path, status: :see_other, notice: "Domain was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_domain
      @domain = Domain.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def domain_params
      params.expect(domain: [ :name, :user_id, :country, :tracked_keywords_count ])
    end
end
