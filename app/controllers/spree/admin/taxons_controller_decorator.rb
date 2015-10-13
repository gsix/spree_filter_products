Spree::Admin::TaxonsController.class_eval do

  before_action :load_options, only: [:create, :edit, :update]
  before_action :split_options, only: [:update]


  protected

  def load_options
    @option_types = Spree::OptionType.order(:name)
  end

  def split_options
    if params[:taxon][:option_type_ids].present?
      params[:taxon][:option_type_ids] = params[:taxon][:option_type_ids].split(',')
    end
  end
end