class EnvironmentsController < ApplicationController
  before_action :set_environment, only: [:show, :edit, :update, :destroy]

  # GET /environments
  # GET /environments.json
  def index
    @environments = Environment.all
  end

  # GET /environments/1
  # GET /environments/1.json
  def show
  end

  # GET /environments/new
  def new
    @environment = Environment.new
  end

  # GET /environments/1/edit
  def edit
  end

  # POST /environments
  # POST /environments.json
  def create
    @environment = Environment.new(environment_params)

    respond_to do |format|
      if @environment.save
        format.html { redirect_to @environment, notice: 'Environment was successfully created.' }
        format.json { render :show, status: :created, location: @environment }
      else
        format.html { render :new }
        format.json { render json: @environment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /environments/1
  # PATCH/PUT /environments/1.json
  def update
    respond_to do |format|
      if @environment.update(environment_params)
        format.html { redirect_to @environment, notice: 'Environment was successfully updated.' }
        format.json { render :show, status: :ok, location: @environment }
      else
        format.html { render :edit }
        format.json { render json: @environment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /environments/1
  # DELETE /environments/1.json
  def destroy
    @environment.destroy
    respond_to do |format|
      format.html { redirect_to environments_url, notice: 'Environment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
  
  def test_suites
    @environment_id = params[:id]
    if @environment_id.present?
      @environment_name = Environment.find(@environment_id).name
      @test_suites = TestSuite.where(environment_id: @environment_id)
    else
      @test_suites = TestSuite.all
    end
  end

  def list_all_reports
    @schedule_cases = Scheduler.find(params[:id])
    @result_cases = ResultCase.where(scheduler_id: params[:id])
    respond_to do |format|  
      format.html{}
    end
  end

  def reports
    logger.debug("SESSION OBJECT #{session[:enviro_id].inspect}")
    id = session[:enviro_id]
    @test_suites = TestSuite.where(environment_id: id).pluck(:id)
    if @test_suites.present?
      logger.debug(" TEST SUITE #{@test_suites} ")
      @test_suites.each do |ts_id|
        @schedule = Array.new
        sch = Scheduler.where(test_suite_id: ts_id).pluck(:id)
        sch.each do |id|
          @schedule << Scheduler.find(id)
          logger.debug(" TEST SUITE #{@schedule.inspect}")
        end
      end
    end
  end
  
  def run_suites
    logger.debug "COMMIT #{params[:commit]}"
    if params[:suite].present?
      params[:suite].each do |s|
        logger.debug "CHECK CHECK SUITE SUITE #{s}"
        suite = TestSuite.find(s[0])
        schedule = Scheduler.new
        schedule.test_suite_id = s[0]
        schedule.scheduled_date = DateTime.now
        schedule.status = "READY"
        schedule.save!
        logger.debug "#{suite.id} #{suite.name}"
        if params[:commit] == "Schedule Now"
          system "/home/newprod/SeleniumWebTester/start.sh"
        end
        # RUNSUITELOGIC put logic for running each test suite here.
      end
    else
      return redirect_to "/environments/#{session[:enviro_id]}/test_suites"
    end
    return redirect_to "/environments/#{session[:enviro_id]}/test_suites"
  end

  def images
    @file_name = params[:file_name]
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_environment
      @environment = Environment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def environment_params
      params.require(:environment).permit(:name, :url, :username, :password, :login_field, :password_field, :action_button,:default_suite_id, :user_emails, :selenium_tester_url, test_suite_ids: [])
    end
end
