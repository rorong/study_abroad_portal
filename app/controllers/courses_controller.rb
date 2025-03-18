class CoursesController < ApplicationController
  def index
    # Clone the params to avoid modifying the original request params
    filtered_params = params.to_unsafe_h.except(:controller, :action)

    if params[:query].present?
      results = Course.search_courses_and_subjects(params[:query])
      @courses = results[:courses]
      @subjects = results[:subjects]
      @tests = results[:tests]
    else
      @courses = Course.all
      @subjects = []
      @tests = []
    end

    # Apply filters only if they exist in the filtered_params
    @courses = @courses.where(intake: filtered_params[:intake]) if filtered_params[:intake].present?
    @courses = @courses.where(current_status: filtered_params[:current_status]) if filtered_params[:current_status].present?
    @courses = @courses.where('title LIKE ?', "%#{filtered_params[:title]}%") if filtered_params[:title].present?
    @courses = @courses.where(delivery_method: filtered_params[:delivery_method]) if filtered_params[:delivery_method].present?
    @courses = @courses.where(institution_id: filtered_params[:institution_id]) if filtered_params[:institution_id].present?
    @courses = @courses.where(department_id: filtered_params[:department_id]) if filtered_params[:department_id].present?
    @courses = @courses.joins(:tags).where(tags: { id: filtered_params[:tag_id] }) if filtered_params[:tag_id].present?
    @courses = @courses.where(course_duration: filtered_params[:course_duration]) if filtered_params[:course_duration].present?
    @courses = @courses.where(education_board_id: filtered_params[:education_board_id]) if filtered_params[:education_board_id].present?
    @courses = @courses.where(level_of_course: filtered_params[:level_of_course]) if filtered_params[:level_of_course].present?
    @courses = @courses.where(internship_period: filtered_params[:internship_period]) if filtered_params[:internship_period].present?
    @courses = @courses.where(application_fee: filtered_params[:application_fee]) if filtered_params[:application_fee].present? 
    if filtered_params[:min_tuition_fee].present? || filtered_params[:max_tuition_fee].present?
      min_fee = filtered_params[:min_tuition_fee].present? ? filtered_params[:min_tuition_fee].to_f : 0
      max_fee = filtered_params[:max_tuition_fee].present? ? filtered_params[:max_tuition_fee].to_f : Float::INFINITY
      @courses = @courses.where(tuition_fee_international: min_fee..max_fee)
    end
    if params[:sort_by] == "tuition_fee_asc"
      @courses = @courses.order(tuition_fee_international: :asc)
    elsif params[:sort_by] == "tuition_fee_desc"
      @courses = @courses.order(tuition_fee_international: :desc)
    end
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def search
    @courses = Course.where("name LIKE ?", "%#{params[:query]}%").pluck(:id, :name)
    respond_to do |format|
      format.json { render json: { courses: @courses } }
    end
  end
end
