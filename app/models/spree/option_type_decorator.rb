Spree::OptionType.class_eval do

    has_many :taxon_option_types, dependent: :destroy, inverse_of: :option_type
    has_many :taxons, through: :taxon_option_types
end