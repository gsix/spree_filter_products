Deface::Override.new(
    virtual_path:       "spree/admin/taxons/_form",
    name:               "add_to_form_options",
    insert_before:      "erb[loud]:contains('field_container :meta_title')",
    text: %Q{
      <div data-hook="admin_taxon_form_option_types">
        <%= f.field_container :option_types, class: ['form-group'] do %>
          <%= f.label :option_type_ids, Spree.t(:filter_option_types) %>

          <% if can? :modify, Spree::OptionType %>
            <%= f.hidden_field :option_type_ids, value: @taxon.option_type_ids.join(',') %>
          <% elsif @taxon.option_types.any? %>
            <ul class="text_list">
              <% @taxon.option_types.each do |type| %>
                <li><%= type.presentation %> (<%= type.name %>)</li>
              <% end %>
            </ul>
          <% else %>
            <div class="alert alert-info"><%= Spree.t(:no_resource_found, resource: :option_types) %></div>
          <% end %>

        <% end %>
      </div>
    }
)

