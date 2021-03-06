# encoding: UTF-8
class CompaniesController < ApplicationController
  before_filter :authorize_user_is_admin, :except => [:show_logo, :properties]

  layout 'admin'

  def edit
    @company = current_user.company
  end

  def score_rules
    @company = current_user.company
  end

  def custom_scripts
    @company = current_user.company
  end

  def update
    @company = current_user.company

    if @company.update_attributes(company_params)
      flash[:success] = t('flash.notice.settings_updated', model: Company.model_name.human)
      redirect_from_last
    else
      flash[:error] = @company.errors.full_messages.join('. ')
      render :action => 'edit'
    end
  end

  # Show a company logo
  def show_logo
    company = Company.find(params[:id])

    if company.logo?
      send_file(company.logo_path, :filename => 'logo', :disposition => 'inline', :type => company.logo_content_type)
    else
      render :nothing => true
    end
  end

  # get company properties in JSON format
  def properties
    @properties = current_user.company.properties
    render :json => @properties
  end

  private

  def company_params
    params.require(:company).permit(:name,
                                    :contact_email,
                                    :logo,
                                    :contact_name,
                                    :subdomain,
                                    :show_wiki,
                                    :suppressed_email_addresses,
                                    :logo_file_name,
                                    :logo_content_type,
                                    :logo_updated_at,
                                    :use_resources,
                                    :use_billing,
                                    :use_score_rules,
                                    preference_attributes: [:incoming_email_project])
  end
end
