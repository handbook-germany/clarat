class OffersController < ApplicationController
  include GmapsVariable
  respond_to :html

  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @offers = build_search_cache.search params[:page]
    @tags = @search_cache.tags_by_facet
    test_location_unavailable
    set_position
    prepare_gmaps_variables @offers
    respond_with @offers
  end

  rescue_from InvalidLocationError do |_error|
    render 'invalid_location', status: 404
  end

  def show
    @offer = Offer.friendly.find(params[:id])
    authorize @offer

    prepare_gmaps_variable @offer
    @contact = Contact.new url: request.url, reporting: true
    respond_with @offer
  end

  private

  def build_search_cache
    search_params = {}
    form_search_params = params.for(SearchForm)[:search_form]
    search_params.merge!(form_search_params) if form_search_params.is_a?(Hash)
    @search_cache = SearchForm.new(search_params)
  end

  def set_position
    @position = @search_cache.geolocation
    if @search_cache.search_location == I18n.t('conf.current_location')
      cookies[:last_search_location] = nil # erase cookie so that next time the current location will be used again
    else
      cookies[:last_search_location] = @search_cache.location_for_cookie # set cookie so that next time the same location will be prefilled
    end
  end

  # See if area is covered and if not instantiate an UpdateRequest
  def test_location_unavailable
    unless @search_cache.nearby?
      @update_request = UpdateRequest.new(
        search_location: @search_cache.search_location
      )
    end
  end
end
