# frozen_string_literal: true

require_relative '../test_helper'

describe OffersController do
  describe "GET 'show'" do
    describe 'for an approved offer' do
      it 'should work (with friendly id)' do
        offer = offers(:basic)
        offer.name = 'bazfuz'
        get :show, params: { id: offer.slug, locale: 'de' }
        assert_response :success
        assert_select 'title', 'basicOfferName | Handbook Germany'
      end

      # it 'should use the correct canonical URL' do
      #   offer = offers(:basic)
      #   get :show, params: { id: offer.slug, locale: 'de' }
      #   assert_includes response.body,
      #                   "http://test.host/family/angebote/#{offer.slug}"
      # end

      it 'shouldnt show on unapproved offer' do
        offer = offers(:basic)
        offer.update_column :aasm_state, :completed
        get :show, params: { id: offer.slug, locale: 'de' }
        assert_redirected_to controller: 'pages', action: 'not_found'
      end

      it 'should redirect to 404 if offer not found' do
        get :show, params: { id: 'doesntexist', locale: 'de' }
        assert_redirected_to controller: 'pages', action: 'not_found'
      end
    end

    describe 'for an expired offer' do
      it 'should work (with friendly id)' do
        offer = offers(:basic)
        offer.update_columns aasm_state: 'expired'
        get :show, params: { id: offer.slug, locale: 'de' }
        assert_response :success
        assert_select 'title', 'basicOfferName | Handbook Germany'
      end

      # it 'should use the correct canonical URL' do
      #   offer = offers(:basic)
      #   offer.update_columns aasm_state: 'expired'
      #   get :show, params: { id: offer.slug, locale: 'de' }
      #   assert_includes response.body,
      #                   "http://test.host/family/angebote/#{offer.slug}"
      # end
    end
  end

  describe "GET 'index'" do
    it 'should work' do
      get :index, params: { locale: 'de' }
      assert_response :success
    end

    it 'should work with "my location"' do
      get :index, params: { locale: 'de', search_form: {
        search_location: I18n.t('conf.current_location'),
        generated_geolocation: I18n.t('conf.default_latlng')
      } }
      assert_response :success
    end
  end
end
