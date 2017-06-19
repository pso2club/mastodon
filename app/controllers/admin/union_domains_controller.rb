# frozen_string_literal: true

module Admin
  class UnionDomainsController < BaseController
    before_action :set_union_domain, only: [:show, :destroy]

    def index
      @union_domains = UnionDomain.page(params[:page])
    end

    def new
      @union_domain = UnionDomain.new
      if params[:mode].present?
        @accounts = Account.local.order(username: :asc) if params[:mode] == "following"
        @accounts = Account.remote.where(unionmember: false).order(domain: :asc, username: :asc) if params[:mode] == "account"
      end
    end

    def create
      @union_domain = UnionDomain.new(resource_params)

      if @union_domain.save
        UnionDomainWorker.perform_async(@union_domain.id)
        redirect_to admin_union_domains_path, notice: I18n.t('admin.union_domains.created_msg')
      else
        render :new
      end
    end

    def show; end

    def destroy
      RemoveUnionDomainService.new.call(@union_domain, retroactive_remove?)
      redirect_to admin_union_domains_path, notice: I18n.t('admin.union_domains.destroyed_msg')
    end

    private

    def set_union_domain
      @union_domain = UnionDomain.find(params[:id])

      if @union_domain.bot?
        @options = { :mode => "following", :count => @union_domain.account.following_count }
      elsif @union_domain.account_id.blank?
        @options = { :mode => "domain", :count => @union_domain.accounts_count }
      else
        @options = { :mode => "account", :count => 1 }
      end
    end

    def resource_params
      params.require(:union_domain).permit(:domain, :account_id, :bot, :mode, :retroactive)
    end

    def retroactive_remove?
      ActiveRecord::Type.lookup(:boolean).cast(resource_params[:retroactive])
    end

  end
end
