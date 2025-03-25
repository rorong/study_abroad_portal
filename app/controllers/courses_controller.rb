class CoursesController < ApplicationController
  def index
    # Clone the params to avoid modifying the original request params
    filtered_params = params.to_unsafe_h.except(:controller, :action)

    # Initialize base query
    @courses = Course.all

    # Apply search query if present
    if params[:query].present?
      results = Course.search_courses_and_subjects(params[:query])
      @courses = results[:courses]
      @subjects = results[:subjects]
      @tests = results[:tests]
    else
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
    # Handle course duration range
    if filtered_params[:min_duration].present? || filtered_params[:max_duration].present?
      min_duration = filtered_params[:min_duration].present? ? filtered_params[:min_duration].to_i : 0
      max_duration = filtered_params[:max_duration].present? ? filtered_params[:max_duration].to_i : Float::INFINITY
      @courses = @courses.where(course_duration: min_duration..max_duration)
    end
    @courses = @courses.where(education_board_id: filtered_params[:education_board_id]) if filtered_params[:education_board_id].present?
    @courses = @courses.where(level_of_course: filtered_params[:level_of_course]) if filtered_params[:level_of_course].present? 
    # Handle internship period range
    if filtered_params[:min_internship].present? || filtered_params[:max_internship].present?
      min_internship = filtered_params[:min_internship].present? ? filtered_params[:min_internship].to_i : 0
      max_internship = filtered_params[:max_internship].present? ? filtered_params[:max_internship].to_i : Float::INFINITY
      @courses = @courses.where(internship_period: min_internship..max_internship)
    end
    # Handle application fee range
    if filtered_params[:min_application_fee].present? || filtered_params[:max_application_fee].present?
      min_fee = filtered_params[:min_application_fee].present? ? filtered_params[:min_application_fee].to_f : 0
      max_fee = filtered_params[:max_application_fee].present? ? filtered_params[:max_application_fee].to_f : Float::INFINITY
      @courses = @courses.where(application_fee: min_fee..max_fee)
    end
    @courses = @courses.joins(:universities).where(universities: { id: filtered_params[:university_id] }) if filtered_params[:university_id].present?
    @courses = @courses.joins(:universities).where(universities: { country: filtered_params[:university_country] }) if filtered_params[:university_country].present?
    @courses = @courses.joins(:universities).where('universities.address LIKE ?', "%#{filtered_params[:university_address]}%") if filtered_params[:university_address].present?
    
    # Add ranking filters
    if filtered_params[:min_world_ranking].present? || filtered_params[:max_world_ranking].present?
      min_rank = filtered_params[:min_world_ranking].present? ? filtered_params[:min_world_ranking].to_i : 0
      max_rank = filtered_params[:max_world_ranking].present? ? filtered_params[:max_world_ranking].to_i : Float::INFINITY
      @courses = @courses.joins(:universities).where(universities: { world_ranking: min_rank..max_rank })
    end
    
    if filtered_params[:min_qs_ranking].present? || filtered_params[:max_qs_ranking].present?
      min_rank = filtered_params[:min_qs_ranking].present? ? filtered_params[:min_qs_ranking].to_i : 0
      max_rank = filtered_params[:max_qs_ranking].present? ? filtered_params[:max_qs_ranking].to_i : Float::INFINITY
      @courses = @courses.joins(:universities).where(universities: { qs_ranking: min_rank..max_rank })
    end
    
    if filtered_params[:min_national_ranking].present? || filtered_params[:max_national_ranking].present?
      min_rank = filtered_params[:min_national_ranking].present? ? filtered_params[:min_national_ranking].to_i : 0
      max_rank = filtered_params[:max_national_ranking].present? ? filtered_params[:max_national_ranking].to_i : Float::INFINITY
      @courses = @courses.joins(:universities).where(universities: { national_ranking: min_rank..max_rank })
    end
    
    if filtered_params[:min_tuition_fee].present? || filtered_params[:max_tuition_fee].present?
      min_fee = filtered_params[:min_tuition_fee].present? ? filtered_params[:min_tuition_fee].to_f : 0
      max_fee = filtered_params[:max_tuition_fee].present? ? filtered_params[:max_tuition_fee].to_f : Float::INFINITY
      @courses = @courses.where(tuition_fee_international: min_fee..max_fee)
    end
    
    if params[:sort_by] == "tuition_fee_asc"
      @courses = @courses.order(tuition_fee_international: :asc)
    elsif params[:sort_by] == "tuition_fee_desc"
      @courses = @courses.order(tuition_fee_international: :desc)
    elsif params[:sort_by] == "application_fee_asc"
      @courses = @courses.order(application_fee: :asc)
    elsif params[:sort_by] == "application_fee_desc"
      @courses = @courses.order(application_fee: :desc)
    end

    # Get the current filtered courses for dynamic filter options
    filtered_courses = @courses.distinct

    # Prepare dynamic filter options based on current filtered results
    @available_institutions = Institution.joins(:courses)
                                      .where(courses: { id: filtered_courses })
                                      .distinct
    
    @available_departments = Department.joins(:courses)
                                     .where(courses: { id: filtered_courses })
                                     .distinct
    
    @available_universities = University.joins(:courses)
                                      .where(courses: { id: filtered_courses })
                                      .distinct
    
    @available_university_countries = University.joins(:courses)
                                              .where(courses: { id: filtered_courses })
                                              .distinct
                                              .pluck(:country)
                                              .compact
    
    @available_intakes = filtered_courses.distinct.pluck(:intake).compact
    @available_statuses = filtered_courses.distinct.pluck(:current_status).compact
    @available_delivery_methods = filtered_courses.distinct.pluck(:delivery_method).compact
    @available_durations = filtered_courses.distinct.pluck(:course_duration).compact
    @available_levels = filtered_courses.distinct.pluck(:level_of_course).compact
    @available_application_fees = filtered_courses.distinct.pluck(:application_fee).compact
    
    @available_tags = Tag.joins(:courses)
                        .where(courses: { id: filtered_courses })
                        .distinct
    
    @available_education_boards = EducationBoard.joins(:courses)
                                              .where(courses: { id: filtered_courses })
                                              .distinct
    @course_count = @courses.count
    @courses = @courses.page(params[:page]).per(10)

    respond_to do |format|
      format.html
      format.turbo_stream { 
        render turbo_stream: turbo_stream.replace(
          "courses_list",
          partial: "courses_list",
          locals: {
            courses: @courses,
            subjects: @subjects,
            tests: @tests,
            institutions: @available_institutions,
            departments: @available_departments,
            tags: @available_tags,
            universities: @available_universities
          }
        )
      }
    end
  end

  def show
    @course = Course.find(params[:id])
    @universities = @course.universities
    @institution = @course.institution
    @department = @course.department
    @tags = @course.tags
    @education_board = @course.education_board
  end

  def search
    query = params[:query].to_s.strip
    Rails.logger.info "Search query: #{query}"
    
    if query.present?
      @courses = Course.joins(:universities)
                      .where("courses.title ILIKE ? OR universities.name ILIKE ?", "%#{query}%", "%#{query}%")
                      .select("courses.id, courses.title as name, universities.name as university_name")
                      .limit(10)
                      .map { |course| [course.id, course.name, course.university_name] }
      Rails.logger.info "Found #{@courses.size} results"
    else
      @courses = []
    end
    
    respond_to do |format|
      format.json { render json: { courses: @courses } }
    end
  end
end
