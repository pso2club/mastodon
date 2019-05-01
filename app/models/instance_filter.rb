# frozen_string_literal: true

class InstanceFilter
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def results
    if params[:limited].present?
      DomainBlock.order(id: :desc)
    elsif params[:union].present?
      UnionDomain.domain
    else
      Account.remote.by_domain_accounts
    end
  end
end
