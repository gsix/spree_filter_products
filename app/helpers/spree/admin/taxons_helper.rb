Spree::Admin::TaxonsHelper.class_eval do
  def option_types_options_for(taxon)
    options = @option_types.map do |option_type|
      selected = taxon.option_types.include?(option_type)
      content_tag(:option,
                  :value    => option_type.id,
                  :selected => ('selected' if selected)) do
        option_type.name
      end
    end.join("").html_safe
  end
end