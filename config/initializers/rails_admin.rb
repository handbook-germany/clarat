RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == PaperTrail ==
  config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new do
      except ['User']
    end
    export
    bulk_delete do
      except ['User']
    end
    show
    edit
    delete do
      except ['User']
    end
    show_in_app

    ## With an audit adapter, you can add:
    history_index
    history_show
  end

  config.model 'Organization' do
    field :name
    field :description do
      css_class "js-count-character"
    end
    field :legal_form
    field :charitable
    field :founded
    field :umbrella
    field :slug do
      read_only do
        bindings[:object].new_record?
      end
    end

    field :websites

    show do
      field :offers
      field :locations
    end
  end

  config.label_methods << :url
  config.model 'Website' do
    field :sort
    field :url
  end

  config.model 'Location' do
    field :organization
    field :name
    field :street
    field :addition
    field :zip
    field :city
    field :federal_state
    field :telephone
    field :second_telephone
    field :fax
    field :email
    field :hq
    field :latitude do
      read_only true
    end
    field :longitude do
      read_only true
    end
    field :websites

    object_label_method :concat_address
  end

  config.model 'FederalState' do
    list do
      field :id do
        sort_reverse false
      end
      field :name
    end
  end

  config.model 'Offer' do
    field :name
    field :description do
      css_class "js-count-character"
    end
    field :todo do
      css_class "js-count-character"
    end
    field :telephone
    field :contact_name
    field :email
    field :reach
    field :frequent_changes
    field :slug do
      read_only do
        bindings[:object].new_record?
      end
    end
    field :location
    field :organization
    field :tags
    field :languages
    field :openings
    field :websites
  end

  config.model 'Opening' do
    field :day
    field :open
    field :close

    object_label_method :concat_day_and_times
  end

  config.model 'Tag' do
    field :name
    field :main
    field :associated_tags

    object_label_method :name_with_optional_asterisk
  end

  config.model 'Language' do
    list do
      field :id do
        sort_reverse false
      end
      field :name
      field :code
      field :offers
    end
  end

  config.label_methods << :email
  config.model 'User' do
    create do
    end
    edit do
      field :email do
        read_only do
          bindings[:object] != bindings[:view].current_user
        end
      end
      field :password do
        visible do
          bindings[:object] == bindings[:view].current_user
        end
      end
    end
  end
end
