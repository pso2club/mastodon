# frozen_string_literal: true

module Admin
  class UnionDomainsController < BaseController
    before_action :set_union_domain, only: [:show, :destroy]

    def index
      @union_domains = UnionDomain.page(params[:page])
    end

    def new
      @union_domain = UnionDomain.new
      @accounts = Account.local
    end

    def create
      @union_domain = UnionDomain.new(resource_params)

      if @union_domain.save
        redirect_to admin_union_domains_path, notice: I18n.t('admin.union_domains.created_msg')
      else
        render :new
      end
    end

    def show; end

    def destroy
      if @union_domain.destroy
        redirect_to admin_union_domains_path, notice: I18n.t('admin.union_domains.destroyed_msg')
      else
        redirect_to admin_union_domains_path, notice: I18n.t('admin.union_domains.delete_error_msg')
      end
    end

    private

    def set_union_domain
      @union_domain = UnionDomain.find(params[:id])
    end

    def resource_params
      params.require(:union_domain).permit(:domain, :account_id)
    end

  end
end
