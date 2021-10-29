class DataImportsController < ApplicationController
  authorize_resource

  before_action :set_import_type
  before_action :set_imports_history, only: %i(index create)

  def index
    @data_import = data_import_class.new
  end

  def create
    @data_import = data_import_class.new(data_import_params)

    if @data_import.enqueue!
      flash[:notice] = t('data_imports.enqueued')
      redirect_to action: :index
    else
      render :index
    end
  end

  def download_import_template
    file = ImportTemplatesFactory.build(@type).generate
    send_file(file.path, filename: data_import_class.template_file_name)
  end

  private

  def set_import_type
    @type = params[:type]
  end

  def set_imports_history
    imports_query = DataImportsQuery.new(data_import_class.all, paginate: {page: params[:page]})
    @data_imports = imports_query.execute.order(created_at: :desc)
  end

  def data_import_params
    params.require(:data_import).permit(:file).merge(user: current_user, account: current_account)
  end

  def data_import_class
    @type.constantize
  end
end
