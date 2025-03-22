# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @github_contributors = GithubService.contributors_with_merged_prs(params[:refresh].present?)
    
    if user_signed_in?
      render :dashboard
    else
      render :index
    end
  end
  
  def dashboard; end
end
