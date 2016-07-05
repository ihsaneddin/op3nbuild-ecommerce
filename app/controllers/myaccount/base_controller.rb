class Myaccount::BaseController < ApplicationController
  helper_method :selected_myaccount_tab, :last_page?, :pagination_rows, :pagination_page
  before_filter :require_user
  before_filter :expire_all_browser_cache

  protected
  def myaccount_tab
    true
  end

  def ssl_required?
    ssl_supported?
  end

  def selected_myaccount_tab(tab)
    tab == ''
  end

  def last_page? collection
    collection.total_pages == collection.current_page
  end

  def pagination_rows
    params[:rows] ||= 25
    params[:rows].to_i
  end

end
