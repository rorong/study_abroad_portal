class UniversitiesController < ApplicationController
  def show
    @university = University.find(params[:id])
    @courses = @university.courses.includes(:department, :institution, :tags, :education_board)
                        .page(params[:page])
                        .per(20)
  end

  def map_search
    @universities = University.where.not(latitude: nil, longitude: nil)
    
    # Apply filters if present
    if params[:query].present?
      query = params[:query].strip.downcase
      @universities = @universities.where(
        "LOWER(name) LIKE ? OR LOWER(country) LIKE ? OR LOWER(city) LIKE ?", 
        "%#{query}%", "%#{query}%", "%#{query}%"
      )
    end
    
    if params[:country].present?
      @universities = @universities.where("LOWER(country) = LOWER(?)", params[:country])
    end
    
    if params[:type_of_university].present?
      @universities = @universities.where("LOWER(type_of_university) = LOWER(?)", params[:type_of_university])
    end

    # Get available options for filters
    @available_countries = University.distinct.pluck(:country).compact.sort
    @available_types = University.distinct.pluck(:type_of_university).compact.sort

    respond_to do |format|
      format.html
      format.json { 
        render json: {
          universities: @universities.as_json(
            only: [:id, :name, :latitude, :longitude, :country, :city, :address, :type_of_university, :world_ranking, :qs_ranking]
          ),
          total_count: @universities.count
        }
      }
    end
  end
end 