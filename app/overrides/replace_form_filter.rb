Deface::Override.new(
    virtual_path:       "spree/taxons/show",
    name:               "replace_form_filter",
    replace:            "erb[loud]:contains('spree/shared/filters')",
    partial:            "filter/filter_custom"
)