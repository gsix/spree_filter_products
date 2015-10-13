module Spree
  class TaxonOptionType < Spree::Base
    belongs_to :taxon, class_name: 'Spree::Taxon', inverse_of: :taxon_option_types
    belongs_to :option_type, class_name: 'Spree::OptionType', inverse_of: :taxon_option_types
    acts_as_list scope: :taxon
  end
end