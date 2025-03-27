class UniversitiesController < ApplicationController
  def show
    @university = University.find(params[:id])
    @courses = @university.courses.includes(:department, :institution, :tags, :education_board)
                        .page(params[:page])
                        .per(20)
  end
end 