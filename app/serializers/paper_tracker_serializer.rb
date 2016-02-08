class PaperTrackerSerializer < LitePaperSerializer
  attributes :paper_type, :submitted_at, :related_users

  def related_users
    object.participants_by_role.map do |(role_name, users)|
      {
        name: role_name,
        users: users
      }
    end
  end
end
