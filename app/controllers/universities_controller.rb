class UniversitiesController < ApplicationController
  def show
    @university = University.find(params[:id])
    @courses = @university.courses.includes(:department, :institution, :tags, :education_board)
                        .page(params[:page])
                        .per(20)
  end

  def map_search
    # Only get universities that have valid coordinates
    @universities = University.where.not(latitude: nil, longitude: nil)
    # Apply location-based search if coordinates are provided
    if params[:lat].present? && params[:lng].present? && params[:query].present?
      lat = params[:lat].to_f
      lng = params[:lng].to_f
      radius_km = 50 # 50km radius
      # Using Haversine formula for distance calculation
      distance_sql = "(6371 * acos(cos(radians(#{lat})) * cos(radians(latitude)) * 
        cos(radians(longitude) - radians(#{lng})) + 
        sin(radians(#{lat})) * sin(radians(latitude))))"
      # Get universities within radius with their distances
      @universities = @universities.select("universities.*, #{distance_sql} as distance")
        .where("#{distance_sql} <= ?", radius_km)
        .order("distance")
    else
      # Show all Australian universities by default
      @universities = @universities.where(country: 'Australia')
        .order(:name)
    end
    respond_to do |format|
      format.html
      format.json { 
        render json: {
          universities: @universities.as_json(
            only: [:id, :name, :latitude, :longitude, :country, :city, :address, :type_of_university, :world_ranking, :qs_ranking]
          ),
          total_count: @universities.size
        }
      }
    end
  end
end 