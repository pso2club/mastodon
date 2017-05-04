# frozen_string_literal: true

class Api::V1::TimelinesController < ApiController
  before_action -> { doorkeeper_authorize! :read }, only: [:home]
  before_action :require_user!, only: [:home]

  respond_to :json

  def home
    @statuses = Feed.new(:home, current_account).get(limit_param(DEFAULT_STATUSES_LIMIT), params[:max_id], params[:since_id])
    @statuses = cache_collection(@statuses)

    set_maps(@statuses)

    next_path = api_v1_home_timeline_url(pagination_params(max_id: @statuses.last.id))    unless @statuses.empty?
    prev_path = api_v1_home_timeline_url(pagination_params(since_id: @statuses.first.id)) unless @statuses.empty?

    set_pagination_headers(next_path, prev_path)

    render :index
  end

  def public
    flags    = timeline_flags()
    @statuses = Status.as_public_timeline(current_account, flags).paginate_by_max_id(limit_param(DEFAULT_STATUSES_LIMIT), params[:max_id], params[:since_id])
    @statuses = cache_collection(@statuses)

    set_maps(@statuses)

    next_path = api_v1_public_timeline_url(pagination_params(max_id: @statuses.last.id))    unless @statuses.empty?
    prev_path = api_v1_public_timeline_url(pagination_params(since_id: @statuses.first.id)) unless @statuses.empty?

    set_pagination_headers(next_path, prev_path)

    render :index
  end

  def tag
    @flags    = timeline_flags()
    @tag      = Tag.find_by(name: params[:id].downcase)
    @statuses = @tag.nil? ? [] : Status.as_tag_timeline(@tag, current_account, @flags).paginate_by_max_id(limit_param(DEFAULT_STATUSES_LIMIT), params[:max_id], params[:since_id])
    @statuses = cache_collection(@statuses)

    set_maps(@statuses)

    next_path = api_v1_hashtag_timeline_url(params[:id], pagination_params(max_id: @statuses.last.id))    unless @statuses.empty?
    prev_path = api_v1_hashtag_timeline_url(params[:id], pagination_params(since_id: @statuses.first.id)) unless @statuses.empty?

    set_pagination_headers(next_path, prev_path)

    render :index
  end

  private

  def cache_collection(raw)
    super(raw, Status)
  end

  def timeline_flags
    #return { local_only: params[:local].present? ? params[:local] : false, union_only: params[:union].present? ? params[:union] : false }
    return { local_only: ActiveRecord::Type::Boolean.new.cast(params[:local]), union_only: ActiveRecord::Type::Boolean.new.cast(params[:union]) }
  end

  #def to_boolean_params(bool)
  #  
  #end
  #
  def pagination_params(core_params)
    params.permit(:local, :union, :limit).merge(core_params)
  end
end
