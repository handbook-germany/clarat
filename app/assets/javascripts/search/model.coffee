# Frontend Search Implementation - Model
# Communicates with the Persister, called by the Presenter.
# Patterns: Model-Template-Controller structure
class Clarat.Search.Model extends ActiveScript.Model
  # We communicate with a remote service instead of a database. This is the
  # equivalent of a regular #save. We create a connection, then send the data

  getMainSearchResults: ->
    @client().search @personalAndRemoteQueries()

  getLocationSupportResults: ->
    @client().search @nearbyAndFacetQueries()

  getQuerySupportResults: ->
    @client().search @facetQueries()

  client: ->
    return @_client ?= algoliasearch Clarat.Algolia.appID, Clarat.Algolia.apiKey

  resetPageVariable: ->
    @assignAttributes {page: 0}

  ## Parent Override

  # Page is always set to 0 unless changed explicitly
  assignAttributes: (changes) ->
    changes.page = 0 unless changes.page
    super changes

  ### PRIVATE METHODS (ue) ###

  nearbyAndFacetQueries: ->
    _.chain [ @nearby_query(), @remote_facet_query(), @personal_facet_query() ]
      .compact()
      .map( (query) -> query.query_hash() )
      .value()
    #_.map [@nearby_query(), @personal_facet_query(), @remote_facet_query()],
    #      (query) -> query.query_hash()

  facetQueries: ->
    _.chain [ @remote_facet_query(), @personal_facet_query() ]
      .compact()
      .map( (query) -> query.query_hash() )
      .value()
    # _.map [@personal_facet_query(), @remote_facet_query()],
      #    (query) -> query.query_hash()

  personalAndRemoteQueries: ->
    @_queries = _.chain [ @personal_query(), @remote_query() ]
      .compact()
      .map( (query) -> query.query_hash() )
      .value()

  personal_query: ->
    new Clarat.Search.Query.Personal(
      @generated_geolocation, @exact_location, @query,
      @facetFilters(), @page, @sort_order
    )

  remote_query: ->
    new Clarat.Search.Query.Remote(
      @generated_geolocation, @isPersonal(), @query,
      @facetFilters(), @page, @sort_order
    )

  nearby_query: ->
    new Clarat.Search.Query.Nearby @generated_geolocation, @section_identifier

  personal_facet_query: ->
    if @isPersonal()
      new Clarat.Search.Query.PersonalFacet(
        @generated_geolocation, @exact_location, @query,
        @facetFilters()
        # @query,  @geolocation, @search_radius, @facetFilters()
      )

  remote_facet_query: ->
    new Clarat.Search.Query.RemoteFacet(
      @generated_geolocation, true, @query,
      @facetFilters()
    )


  isPersonal: ->
    @contact_type == 'personal'

  ADVANCED_SEARCH_FILTERS: [
    'target_audience', 'exclusive_gender', 'language', 'residency_status'
  ]

  facetFilters: ->
    filterArray = @ADVANCED_SEARCH_FILTERS.map((type) =>
      filter = @[type]
      if filter then "_#{type}_filters:#{filter}" else null
    ).filter (element) -> element # compact / remove all falsey values
    filterArray.push("section_identifier:#{@section_identifier}")
    filterArray

  # # wide radius or use exact location
  # search_radius: ->
  #   if search_form.exact_location
  #     100
  #   else
  #     50_000


  getFilters: ->
    _.merge(@filters, { sort_order: @getSortOrders() })

  getSortOrders: ->
    [
      display_name: I18n.t('js.search.sort.nearby')
      identifier: 'nearby'
      selected: @sort_order == 'nearby'
    ,
      display_name: I18n.t('js.search.sort.relevance')
      identifier: 'relevance'
      selected: @sort_order == 'relevance'
    ]
