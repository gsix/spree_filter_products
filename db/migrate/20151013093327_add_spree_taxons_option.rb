class AddSpreeTaxonsOption < ActiveRecord::Migration
  def change
    create_table :spree_taxon_option_types do |t|
      t.belongs_to :taxon, index: true
      t.belongs_to :option_type, index: true
      t.integer :position, index: true
    end
  end
end
