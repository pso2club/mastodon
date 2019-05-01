# frozen_string_literal: true

module Admin
  class UnionDomainsController < BaseController
    before_action :set_union_domain, only: [:show, :destroy]

    def index
      authorize :union_domain, :index?
      @union_domains = UnionDomain.page(params[:page])
    end

    def new
      authorize :union_domain, :create?
      @union_domain = UnionDomain.new
      if params[:mode].present?
        @accounts = Account.local.order(username: :asc) if params[:mode] == 'following'
        @accounts = Account.remote.where(unionmember: false).order(domain: :asc, username: :asc) if params[:mode] == 'account'
        @union_domain = UnionDomain.new(domain: params[:_domain]) if params[:mode] == 'domain'
        @union_domain = UnionDomain.new(account_id: params[:_account_id]) if params[:mode] == 'following'
      end
    end

    def create
      authorize :union_domain, :create?

      @union_domain = UnionDomain.new(resource_params)

      if @union_domain.save
        UnionDomainWorker.perform_async(@union_domain.id)
        log_action :create, @union_domain
        if @union_domain.account_id == nil
          redirect_to admin_instances_path(union: '1'), notice: I18n.t('admin.union_domains.created_msg')
        else
          redirect_to admin_accounts_path(@union_domain.account_id), notice: I18n.t('admin.union_domains.created_msg')
        end
      else
        render :new
      end
    end

    def show
      authorize @union_domain, :show?
    end

    def destroy
      authorize @union_domain, :destroy?
      RemoveUnionDomainService.new.call(@union_domain, retroactive_remove?)
      log_action :destroy, @union_domain
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
