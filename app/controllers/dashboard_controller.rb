# renders the application dashboard for the root company
class DashboardController < ApplicationController
  def index
    @presenter = DashboardChartPresenter.new(selected_company: current_company, user: current_user, companies: displayed_companies, date: Date.today)
    @statistics_presenter = StatisticsPresenter.new(selected_company: current_company, user: current_user, companies: displayed_companies)
    @presenter.set_gon_variables(gon)
    @activity_section_presenter = ActivitySectionPresenter.new(params: params, source: current_company.root? ? current_account : current_company, account: current_account, user: current_user)
  end
end
