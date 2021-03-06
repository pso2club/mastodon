# frozen_string_literal: true

class AfterRemoteFollowWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull', retry: 5

  attr_reader :follow

  def perform(follow_id)
    @follow = Follow.find(follow_id)
    process_follow_service if processing_required?
    process_union_domain_service if UnionDomain.bot?(@follow.account_id)
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def process_follow_service
    follow.destroy
    FollowService.new.call(follow.account, updated_account.acct)
  end

  def process_union_domain_service
    Account.update(@follow.target_account_id, { :unionmember => true })
  end

  def updated_account
    @_updated_account ||= FetchRemoteAccountService.new.call(follow.target_account.remote_url)
  end

  def processing_required?
    !updated_account.nil? && updated_account.locked?
  end
end
