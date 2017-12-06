# Returns papers being searched for by admins for display in Paper Tracker
class PaperTrackerController < ApplicationController
  before_action :authenticate_user!

  respond_to :json

  def index
    raise AuthorizationError if journal_ids.empty?

    # show all papers that user is connected to across all journals
    papers = order(QueryParser.new(current_user: current_user)
             .build(params[:query] || '')
             .includes(:file, :journal)
             .where(journal_id: journal_ids)
             .where.not(publishing_state: :unsubmitted))
             .page(page)

    respond_with papers,
                 each_serializer: PaperTrackerSerializer,
                 root: 'papers',
                 meta: metadata(papers)
  end

  private

  def page
    params[:page].present? ? params[:page] : 1
  end

  def order(query)
    if ["handling_editor", "cover_editor"].include? params[:orderBy]
      order_by_role(query, params[:orderBy].titleize)
    else
      query.reorder("#{column} #{order_dir}")
    end
  end

  def order_by_role(query, role)
    role_ids = Role.where(journal_id: journal_ids, name: role)
               .map(&:id)
               .join(", ")
    query.joins(<<-SQL.strip_heredoc)
        LEFT JOIN assignments
        ON assignments.assigned_to_id = papers.id AND
        assignments.assigned_to_type='Paper' AND
        assignments.role_id IN (#{role_ids})
      SQL
      .joins(<<-SQL.strip_heredoc)
        LEFT JOIN users
        ON users.id = assignments.user_id
      SQL
      .select('papers.*, users.last_name')
      .order("users.last_name #{order_dir}")
  end

  def column
    Paper.column_names.include?(params[:orderBy]) ? params[:orderBy] : 'submitted_at'
  end

  def order_dir
    params[:orderDir] == 'desc' ? 'desc' : 'asc'
  end

  def metadata(papers)
    {
      totalCount: papers.total_count, # needs to be called on relation.page
      perPage: Kaminari.config.default_per_page,
      page: page
    }
  end

  def journal_ids
    @journal_ids ||= current_user.filter_authorized(
      :view_paper_tracker,
      Journal,
      participations_only: false
    ).objects
  end

end
