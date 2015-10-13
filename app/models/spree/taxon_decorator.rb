Spree::Taxon.class_eval do

    has_many :taxon_option_types, dependent: :destroy, inverse_of: :taxon
    has_many :option_types, through: :taxon_option_types

    after_create :build_variants_from_option_values_hash, if: :option_values_hash

    attr_accessor :option_values_hash

    alias :options :taxon_option_types

    # Builds variants from a hash of option types & values
    def build_variants_from_option_values_hash
      ensure_option_types_exist_for_values_hash
      values = option_values_hash.values
      values = values.inject(values.shift) { |memo, value| memo.product(value).map(&:flatten) }

      values.each do |ids|
        variants.create(
          option_value_ids: ids
        )
      end
      save
    end

    # Ensures option_types and taxon_option_types exist for keys in option_values_hash
    def ensure_option_types_exist_for_values_hash
      return if option_values_hash.nil?
      required_option_type_ids = option_values_hash.keys.map(&:to_i)
      missing_option_type_ids = required_option_type_ids - option_type_ids
      missing_option_type_ids.each do |id|
        taxon_option_types.create(option_type_id: id)
      end
    end


end