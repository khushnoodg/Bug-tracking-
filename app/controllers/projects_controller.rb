class ProjectsController < ApplicationController
  before_action :set_project, only: %i[ show edit update destroy ]
  before_action :authenticate_user!
  load_and_authorize_resource 
  # GET /projects or /projects.json
  def index
    @projects = Project.all
  end

  # GET /projects/1 or /projects/1.json
  def show
    @project = Project.find(params[:id])
    @bugzs = @project.bugzs
    @new_bug = @project.bugzs.build
  end

  # GET /projects/new
  def new
    @project = Project.new
    @project.proj_users.build
  end

  # GET /projects/1/edit
  
  def edit
  end

  # POST /projects or /projects.json
  def create
    @project = Project.new(project_params)
    respond_to do |format|
      if @project.save
        format.html { redirect_to project_url(@project), notice: "Project was successfully created." }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1 or /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to project_url(@project), notice: "Project was successfully updated." }
        format.json { render :show, status: :ok, location: @project }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1 or /projects/1.json
  def destroy
    if current_user.user_type == 'qa'
      respond_to do |format|
        format.html { redirect_to projects_url, notice: "YOu Are QA You cannot DElete Project ." }
        format.json { head :no_content }
      end
    else
    @project.destroy!
    respond_to do |format|
      format.html { redirect_to projects_url, notice: "Project was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  end
  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { render_error_page(exception) }
      # You can add more formats as needed (e.g., JSON)
    end
  end
  private
  def render_error_page(exception)
    @exception = exception
    render "shared/access_denied", status: :forbidden
    # You can create a shared/access_denied.html.erb file for the error page
  end
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end
    def bugz_params
      params.require(:bugz).permit(:title, :deadline, :b_type, :status, :project_id,:image)
    end
    # Only allow a list of trusted parameters through.
    def project_params
      params.require(:project).permit(:name, proj_users_attributes: [:id,:project_id, :user_id,:_destroy])
    end
end
