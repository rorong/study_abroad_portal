class CoursesController < ApplicationController
  def index
    # Clone the params to avoid modifying the original request params
    filtered_params = params.to_unsafe_h.except(:controller, :action)

    # Initialize base query with eager loading to reduce N+1 queries
    @courses = Course.includes(
      :universities,
      :institution,
      :department,
      :tags,
      :education_board,
      :course_requirement,
      :course_test_requirements,
      :course_subject_requirements
    )

    # Apply search query if present
    if params[:query].present?
      results = Course.search_courses_and_subjects(params[:query])
      @courses_by_university = results[:courses_by_university]
      @subjects = results[:subjects]
      @tests = results[:tests]
      @courses = @courses.where(id: results[:courses_by_university].values.flatten.map(&:id))
    else
      @courses_by_university = {}
      @subjects = []
      @tests = []
    end

    # Build conditions array for better query performance
    conditions = []
    condition_params = []

    # Apply filters using conditions array
    if filtered_params[:intake].present?
      conditions << "courses.intake = ?"
      condition_params << filtered_params[:intake]
    end

    if filtered_params[:current_status].present?
      conditions << "courses.current_status = ?"
      condition_params << filtered_params[:current_status]
    end

    if filtered_params[:title].present?
      conditions << "courses.title LIKE ?"
      condition_params << "%#{filtered_params[:title]}%"
    end

    if filtered_params[:delivery_method].present?
      conditions << "courses.delivery_method = ?"
      condition_params << filtered_params[:delivery_method]
    end

    if filtered_params[:institution_id].present?
      conditions << "courses.institution_id = ?"
      condition_params << filtered_params[:institution_id]
    end

    if filtered_params[:department_id].present?
      conditions << "courses.department_id = ?"
      condition_params << filtered_params[:department_id]
    end

    if filtered_params[:allow_backlogs].present?
      conditions << "courses.allow_backlogs = ?"
      condition_params << filtered_params[:allow_backlogs]
    end

    if filtered_params[:education_board_id].present?
      conditions << "courses.education_board_id = ?"
      condition_params << filtered_params[:education_board_id]
    end

    if filtered_params[:level_of_course].present?
      conditions << "courses.level_of_course = ?"
      condition_params << filtered_params[:level_of_course]
    end

    # Apply all conditions at once
    @courses = @courses.where(conditions.join(" AND "), *condition_params) if conditions.any?

    # Handle joins separately for better performance
    if filtered_params[:tag_id].present?
      @courses = @courses.joins(:tags).where(tags: { id: filtered_params[:tag_id] })
    end

    if filtered_params[:lateral_entry_possible].present?
      @courses = @courses.joins(:course_requirement)
                        .where(course_requirements: { lateral_entry_possible: filtered_params[:lateral_entry_possible] })
    end

    if filtered_params[:type_of_university].present?
      @courses = @courses.joins(:universities)
                        .where(universities: { type_of_university: filtered_params[:type_of_university] })
    end

    # Handle distance-based filtering with optimized query
    if filtered_params[:latitude].present? && filtered_params[:longitude].present?
      lat = filtered_params[:latitude].to_f
      lng = filtered_params[:longitude].to_f
      distance = 50 # 50 km radius
      
      @courses = @courses.joins(:universities)
                        .where("(
                          6371 * acos(
                            cos(radians(?)) * cos(radians(universities.lat)) *
                            cos(radians(universities.long) - radians(?)) +
                            sin(radians(?)) * sin(radians(universities.lat))
                          )
                        ) <= ?", lat, lng, lat, distance)
    end

    # Handle ranges with optimized queries
    if filtered_params[:min_duration].present? || filtered_params[:max_duration].present?
      min_duration = filtered_params[:min_duration].present? ? filtered_params[:min_duration].to_i : 0
      max_duration = filtered_params[:max_duration].present? ? filtered_params[:max_duration].to_i : Float::INFINITY
      @courses = @courses.where(course_duration: min_duration..max_duration)
    end

    if filtered_params[:min_internship].present? || filtered_params[:max_internship].present?
      min_internship = filtered_params[:min_internship].present? ? filtered_params[:min_internship].to_i : 0
      max_internship = filtered_params[:max_internship].present? ? filtered_params[:max_internship].to_i : Float::INFINITY
      @courses = @courses.where(internship_period: min_internship..max_internship)
    end

    if filtered_params[:min_application_fee].present? || filtered_params[:max_application_fee].present?
      min_fee = filtered_params[:min_application_fee].present? ? filtered_params[:min_application_fee].to_f : 0
      max_fee = filtered_params[:max_application_fee].present? ? filtered_params[:max_application_fee].to_f : Float::INFINITY
      @courses = @courses.where(application_fee: min_fee..max_fee)
    end

    # Handle university filters
    if filtered_params[:university_id].present?
      @courses = @courses.joins(:universities)
                        .where(universities: { id: filtered_params[:university_id] })
    end

    if filtered_params[:university_country].present?
      @courses = @courses.joins(:universities)
                        .where(universities: { country: filtered_params[:university_country] })
    end

    if filtered_params[:university_address].present? && !filtered_params[:latitude].present?
      @courses = @courses.joins(:universities)
                        .where('universities.address LIKE ?', "%#{filtered_params[:university_address]}%")
    end

    # Handle ranking filters with optimized queries
    if filtered_params[:min_world_ranking].present? || filtered_params[:max_world_ranking].present?
      min_rank = filtered_params[:min_world_ranking].present? ? filtered_params[:min_world_ranking].to_i : 0
      max_rank = filtered_params[:max_world_ranking].present? ? filtered_params[:max_world_ranking].to_i : Float::INFINITY
      @courses = @courses.joins(:universities)
                        .where(universities: { world_ranking: min_rank..max_rank })
    end

    if filtered_params[:min_qs_ranking].present? || filtered_params[:max_qs_ranking].present?
      min_rank = filtered_params[:min_qs_ranking].present? ? filtered_params[:min_qs_ranking].to_i : 0
      max_rank = filtered_params[:max_qs_ranking].present? ? filtered_params[:max_qs_ranking].to_i : Float::INFINITY
      @courses = @courses.joins(:universities)
                        .where(universities: { qs_ranking: min_rank..max_rank })
    end

    if filtered_params[:min_national_ranking].present? || filtered_params[:max_national_ranking].present?
      min_rank = filtered_params[:min_national_ranking].present? ? filtered_params[:min_national_ranking].to_i : 0
      max_rank = filtered_params[:max_national_ranking].present? ? filtered_params[:max_national_ranking].to_i : Float::INFINITY
      @courses = @courses.joins(:universities)
                        .where(universities: { national_ranking: min_rank..max_rank })
    end

    if filtered_params[:min_tuition_fee].present? || filtered_params[:max_tuition_fee].present?
      min_fee = filtered_params[:min_tuition_fee].present? ? filtered_params[:min_tuition_fee].to_f : 0
      max_fee = filtered_params[:max_tuition_fee].present? ? filtered_params[:max_tuition_fee].to_f : Float::INFINITY
      @courses = @courses.where(tuition_fee_international: min_fee..max_fee)
    end

    # Handle sorting
    case params[:sort_by]
    when "tuition_fee_asc"
      @courses = @courses.order(tuition_fee_international: :asc)
    when "tuition_fee_desc"
      @courses = @courses.order(tuition_fee_international: :desc)
    when "application_fee_asc"
      @courses = @courses.order(application_fee: :asc)
    when "application_fee_desc"
      @courses = @courses.order(application_fee: :desc)
    end

    # Get total count for pagination without loading all records
    @course_count = @courses.count

    # Apply pagination after all filters
    @courses = @courses.page(params[:page]).per(20)

    # Check if any filters are active
    has_filters = filtered_params.any? { |key, value| value.present? } || params[:query].present?

    # Get filter options based on whether filters are active
    if has_filters
      filtered_course_ids = @courses.pluck(:id)
      @available_institutions = Institution.joins(:courses)
                                        .where(courses: { id: filtered_course_ids })
                                        .distinct
      
      @available_departments = Department.joins(:courses)
                                       .where(courses: { id: filtered_course_ids })
                                       .distinct
      
      @available_universities = University.joins(:courses)
                                        .where(courses: { id: filtered_course_ids })
                                        .distinct
      
      @available_university_countries = University.joins(:courses)
                                                .where(courses: { id: filtered_course_ids })
                                                .distinct
                                                .pluck(:country)
                                                .compact
      
      @available_university_types = University.joins(:courses)
                                            .where(courses: { id: filtered_course_ids })
                                            .distinct
                                            .pluck(:type_of_university)
                                            .compact
      
      @available_intakes = @courses.distinct.pluck(:intake).compact
      @available_statuses = @courses.distinct.pluck(:current_status).compact
      @available_delivery_methods = @courses.distinct.pluck(:delivery_method).compact
      @available_durations = @courses.distinct.pluck(:course_duration).compact
      @available_levels = @courses.distinct.pluck(:level_of_course).compact
      @available_application_fees = @courses.distinct.pluck(:application_fee).compact
      
      @available_tags = Tag.joins(:courses)
                          .where(courses: { id: filtered_course_ids })
                          .distinct
      
      @available_education_boards = EducationBoard.joins(:courses)
                                                .where(courses: { id: filtered_course_ids })
                                                .distinct
    else
      # If no filters are active, get all available options with optimized queries
      @available_institutions = Institution.joins(:courses).distinct
      @available_departments = Department.joins(:courses).distinct
      @available_universities = University.joins(:courses).distinct
      @available_university_countries = University.distinct.pluck(:country).compact
      @available_university_types = University.distinct.pluck(:type_of_university).compact
      @available_intakes = Course.distinct.pluck(:intake).compact
      @available_statuses = Course.distinct.pluck(:current_status).compact
      @available_delivery_methods = Course.distinct.pluck(:delivery_method).compact
      @available_durations = Course.distinct.pluck(:course_duration).compact
      @available_levels = Course.distinct.pluck(:level_of_course).compact
      @available_application_fees = Course.distinct.pluck(:application_fee).compact
      @available_tags = Tag.joins(:courses).distinct
      @available_education_boards = EducationBoard.joins(:courses).distinct
    end

    # Group courses by university with optimized query
    if params[:query].present?
      filtered_course_ids = @courses.pluck(:id)
      @courses_by_university = @courses_by_university.transform_values do |courses|
        courses.select { |course| filtered_course_ids.include?(course.id) }
      end.reject { |_, courses| courses.empty? }
    else
      @courses_by_university = @courses.joins(:universities)
                                     .group_by { |course| course.universities.first }
                                     .reject { |_, courses| courses.empty? }
    end

    respond_to do |format|
      format.html
      format.turbo_stream { 
        render turbo_stream: turbo_stream.replace(
          "courses_list",
          partial: "courses_list",
          locals: {
            courses: @courses,
            courses_by_university: @courses_by_university,
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

  def map
    @universities = University.where.not(latitude: nil, longitude: nil)
    Rails.logger.info "Found #{@universities.count} universities with coordinates"
    @universities.each do |u|
      Rails.logger.info "University: #{u.name}, Lat: #{u.latitude}, Long: #{u.longitude}"
    end
  end
end
