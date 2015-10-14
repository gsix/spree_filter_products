module Spree
  module Core
    module ProductFilters
      # Example: filtering by price
      #   The named scope just maps incoming labels onto their conditions, and builds the conjunction
      #   'price' is in the base scope's context (ie, "select foo from products where ...") so
      #     we can access the field right away
      #   The filter identifies which scope to use, then sets the conditions for each price range
      #
      # If user checks off three different price ranges then the argument passed to
      # below scope would be something like ["$10 - $15", "$15 - $18", "$18 - $20"]
      #
      Spree::Product.add_search_scope :price_range_any do |*opts|
        conds = opts.map {|o| Spree::Core::ProductFilters.price_filter[:conds][o]}.reject { |c| c.nil? }
        scope = conds.shift
        conds.each do |new_scope|
          scope = scope.or(new_scope)
        end
        Spree::Product.joins(master: :default_price).where(scope)
      end

      def ProductFilters.format_price(amount)
        Spree::Money.new(amount)
      end

      def ProductFilters.price_filter
        v = Spree::Price.arel_table
        conds = [ [ Spree.t(:under_price, price: format_price(10))     , v[:amount].lteq(10)],
                  [ "#{format_price(10)} - #{format_price(15)}"        , v[:amount].in(10..15)],
                  [ "#{format_price(15)} - #{format_price(18)}"        , v[:amount].in(15..18)],
                  [ "#{format_price(18)} - #{format_price(20)}"        , v[:amount].in(18..20)],
                  [ Spree.t(:or_over_price, price: format_price(20)) , v[:amount].gteq(20)]]
        {
          name:   Spree.t(:price_range),
          scope:  :price_range_any,
          conds:  Hash[*conds.flatten],
          labels: conds.map { |k,v| [k, k] }
        }
      end


      # Example: filtering by possible brands
      #
      # First, we define the scope. Two interesting points here: (a) we run our conditions
      #   in the scope where the info for the 'brand' property has been loaded; and (b)
      #   because we may want to filter by other properties too, we give this part of the
      #   query a unique name (which must be used in the associated conditions too).
      #
      # Secondly, the filter. Instead of a static list of values, we pull out all existing
      #   brands from the db, and then build conditions which test for string equality on
      #   the (uniquely named) field "p_brand.value". There's also a test for brand info
      #   being blank: note that this relies on with_property doing a left outer join
      #   rather than an inner join.
      Spree::Product.add_search_scope :brand_any do |*opts|
        conds = opts.map {|o| ProductFilters.brand_filter[:conds][o]}.reject { |c| c.nil? }
        scope = conds.shift
        conds.each do |new_scope|
          scope = scope.or(new_scope)
        end
        Spree::Product.with_property('brand').where(scope)
      end

      def ProductFilters.brand_filter
        brand_property = Spree::Property.find_by(name: 'brand')
        brands = brand_property ? Spree::ProductProperty.where(property_id: brand_property.id).pluck(:value).uniq.map(&:to_s) : []
        pp = Spree::ProductProperty.arel_table
        conds = Hash[*brands.map { |b| [b, pp[:value].eq(b)] }.flatten]
        {
          name:   'Brands',
          scope:  :brand_any,
          conds:  conds,
          labels: (brands.sort).map { |k| [k, k] }
        }
      end

      # Example: a parameterized filter
      #   The filter above may show brands which aren't applicable to the current taxon,
      #   so this one only shows the brands that are relevant to a particular taxon and
      #   its descendants.
      #
      #   We don't have to give a new scope since the conditions here are a subset of the
      #   more general filter, so decoding will still work - as long as the filters on a
      #   page all have unique names (ie, you can't use the two brand filters together
      #   if they use the same scope). To be safe, the code uses a copy of the scope.
      #
      #   HOWEVER: what happens if we want a more precise scope?  we can't pass
      #   parametrized scope names to Ransack, only atomic names, so couldn't ask
      #   for taxon T's customized filter to be used. BUT: we can arrange for the form
      #   to pass back a hash instead of an array, where the key acts as the (taxon)
      #   parameter and value is its label array, and then get a modified named scope
      #   to get its conditions from a particular filter.
      #
      #   The brand-finding code can be simplified if a few more named scopes were added to
      #   the product properties model.
      # Spree::Product.add_search_scope :selective_brand_any do |*opts|
      #   Spree::Product.brand_any(*opts)
      # end

      Spree::Product.add_search_scope :options do |*options|
        value_ids = [options].flatten
        type_ids = []
        value = value_ids.is_a?(Spree::OptionValue) ? value_ids : Spree::OptionValue.find(value_ids)
        value.each do |val|
          val.variants.each do |var|
            type_ids << var.id
          end
        end
        Spree::Product.where("spree_products.id in (select product_id from spree_variants where id in (?))", type_ids.is_a?(Spree::Variant) ? type_ids : Spree::Variant.find(type_ids))
      end

      def ProductFilters.taxons_options(taxon)
        return [] if taxon.nil?
        return Spree::Core::ProductFilters.taxons_options(taxon.parent) if taxon.option_types.empty?
        options = []
        taxon.option_types.each do |option|
          options.push({ name: option.presentation, scope: :options, labels: option.option_values.map { |t| [t.name, t.id] } })
        end
        options
      end

      # Provide filtering on the immediate children of a taxon
      #
      # This doesn't fit the pattern of the examples above, so there's a few changes.
      # Firstly, it uses an existing scope which was not built for filtering - and so
      # has no need of a conditions mapping, and secondly, it has a mapping of name
      # to the argument type expected by the other scope.
      #
      # This technique is useful for filtering on objects (by passing ids) or with a
      # scope that can be used directly (eg. testing only ever on a single property).
      #
      # This scope selects products in any of the active taxons or their children.
      #

      Spree::Product.add_search_scope :taxons_id_in_tree_any do |*taxons|
        taxons = [taxons].flatten
        Spree::Product.where("spree_products.id in (select product_id from spree_products_taxons where taxon_id in (?))", taxons.map {|i| i.is_a?(Spree::Taxon) ? i : Spree::Taxon.find(i)}.reject {|t| t.nil?}.map  {|t| [t] + t.descendants}.flatten)
      end

      def ProductFilters.taxons_below(taxon)
        return Spree::Core::ProductFilters.all_taxons if taxon.nil?
        {
          name:   'Taxons under ' + taxon.name,
          scope:  :taxons_id_in_tree_any,
          labels: taxon.children.sort_by(&:position).map { |t| [t.name, t.id] },
          conds:  nil
        }
      end

      # Filtering by the list of all taxons
      #
      # Similar idea as above, but we don't want the descendants' products, hence
      # it uses one of the auto-generated scopes from Ransack.
      #
      # idea: expand the format to allow nesting of labels?
      def ProductFilters.all_taxons
        taxons = Spree::Taxonomy.all.map { |t| [t.root] + t.root.descendants }.flatten
        {
          name:   'All taxons',
          scope:  :taxons_id_in_tree_any,
          labels: taxons.sort_by(&:name).map { |t| [t.name, t.id] },
          conds:  nil # not needed
        }
      end
    end
  end
end
