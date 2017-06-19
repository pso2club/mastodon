# frozen_string_literal: true

class UnionDomainService < BaseService
  attr_reader :union_domain

  def call(union_domain)
    @union_domain = union_domain
    process_union_domain
  end

  private

  def process_union_domain
    if union_domain.bot?
      bot_accounts!
    elsif union_domain.account_id.present?
      union_member!
    else
      union_accounts!
    end
  end

  def bot_accounts!
    bot_followed_accounts.in_batches.update_all(unionmember: true)
  end

  def union_member!
    Account.update(union_domain.account.id, { :unionmember => true })
    Pubsubhubbub::SubscribeWorker.perform_async(union_domain.account.id) unless union_domain.account.subscribed?
  end

  def union_accounts!
    union_domain_accounts.in_batches.update_all(unionmember: true)
  end

  def unionized_domain
    union_domain.domain
  end

  def bot_follows
    Follow.select(:target_account_id).where(account_id: union_domain.account.id)
  end

  def bot_followed_accounts
    Account.where(id: bot_follows).where(unionmember: false)
  end

  def union_domain_accounts
    Account.where(domain: unionized_domain)
  end

end
