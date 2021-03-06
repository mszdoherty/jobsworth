# encoding: UTF-8
class CustomAttributesController < ApplicationController
  before_filter :authorize_user_is_admin
  before_filter :check_type_param, only: [:edit, :update]

  layout 'admin'

  def index
  end

  def edit
    @attributes = CustomAttribute.attributes_for(current_user.company, params[:type])
  end

  def update
    update_existing_attributes(custom_attributes_params)
    create_new_attributes(custom_attributes_params) if params[:new_custom_attributes]

    flash[:success] = t('flash.notice.model_updated', model: CustomAttribute.model_name.human)
    redirect_to(action: 'edit', type: params[:type])
  end

  def fields
    render(:partial => 'attribute', :locals => {:attribute => CustomAttribute.new})
  end

  def choice
    attribute = CustomAttribute.new
    if params[:id]
      attribute = current_user.company.custom_attributes.find(params[:id])
    end

    render(:partial => 'choice', :locals => {
        :attribute => attribute, :choice => CustomAttributeChoice.new})
  end

  private

  def check_type_param
    redirect_to root_path if params[:type].blank?
  end

  def update_existing_attributes(params)
    attributes = CustomAttribute.attributes_for(current_user.company, params[:type])

    updated = []
    (params[:custom_attributes] || {}).each do |id, values|
      # need to ensure this is set so can delete all
      values[:choice_attributes] ||= {}

      attr = attributes.detect { |ca| ca.id == id.to_i }
      updated << attr

      attr.update_attributes(values)
    end
    missing = attributes - updated
    missing.each { |ca| ca.destroy }
  end

  def create_new_attributes(params)
    attributes = CustomAttribute.attributes_for(current_user.company, params[:type])
    offset = attributes.length

    params[:new_custom_attributes].each_with_index do |values, i|
      values[:attributable_type] = params[:type]
      values[:position] = offset + i
      current_user.company.custom_attributes.create(values)
    end
  end

  def custom_attributes_params
    params.require(:custom_attributes).permit(:company_id,
                                              :attributable_type,
                                              :display_name,
                                              :ldap_attribute_type,
                                              :mandatory,
                                              :multiple,
                                              :max_length,
                                              :position)
  end
end
