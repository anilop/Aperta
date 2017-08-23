require 'support/wait_for_ajax'
require 'support/pages/page_fragment'

#
# Page expects a path and asserts against it. Uses Rails routing helpers to accomplish this.
#
class Page < PageFragment
  include Capybara::DSL
  include Capybara::Select2

  class << self
    include Capybara::DSL

    attr_reader :_path_regex

    def path(path_sym)
      all_routes = Rails.application.routes.routes
      inspector = ActionDispatch::Routing::RoutesInspector.new(all_routes)
      route = inspector.instance_variable_get(:@routes).detect { |p| p.name == path_sym.to_s }
      @_path = "#{path_sym}_path"
      @_path_regex = ActionDispatch::Routing::RouteWrapper.new(route).json_regexp
    end

    def visit(args = [], sync_on: nil)
      page.visit Rails.application.routes.url_helpers.send @_path, *args
      page.has_content? sync_on if sync_on
      new
    end

    def view_task_overlay(paper, task, opts = {})
      new.view_task_overlay(paper, task, opts)
    end

    def view_paper(paper)
      new.view_paper(paper)
    end

    def view_task(task)
      new.view_task(task)
    end

    def view_paper_workflow(paper)
      new.view_paper_workflow(paper)
    end
  end

  def initialize(element = nil, context: nil)
    super(element || page, context: context)
  end

  def reload(sync_on: nil)
    visit page.current_path
    page.has_content? sync_on if sync_on
  end

  def view_paper(paper)
    visit "/papers/#{paper.short_doi}"
  end

  def view_task(task)
    visit "/papers/#{task.paper.short_doi}/tasks/#{task.id}"
  end

  def view_paper_workflow(paper)
    visit "/papers/#{paper.short_doi}/workflow"
  end

  def notice
    find('p.notice')
  end

  def navigate_to_dashboard
    find('.main-nav-item-app-name').click
    wait_for_ajax
    DashboardPage.new
  end

  def view_task_overlay(paper, task, opts = {})
    visit "/papers/#{paper.to_param}/tasks/#{task.id}"
    class_name =
      (task.title.split(' ')
      .map(&:capitalize)
      .join(' ').delete(' ') + "Overlay")
    overlay_class ||= begin
                        class_name.constantize
                      rescue NameError
                        CardOverlay
                      end
    overlay_class.new session.find(".overlay")
  end

  def sign_out
    # Don't visit CAS logout route in CI
    ClimateControl.modify CAS_LOGOUT_URL: nil do
      find('.main-nav-user-section-header').click
      find('#nav-signout').click

      within ".auth-container" do
        find(".auth-flash", text: "Signed out successfully.")
      end
    end
    wait_for_ajax
  end
end
