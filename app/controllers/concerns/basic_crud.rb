module BasicCrud
  extend ActiveSupport::Concern
  include JsonApi

  included do
    load_and_authorize_resource find_by: :uid
  end

  class_methods do
    def index_sort_params(params = {})
      cattr_accessor :sort_params
      self.sort_params = params
    end
  end

  def index
    mutate_collection do |scope|
      response.set_header('X-Total-Count', scope.count(:all))
      scope = scope.order(sort_params) if methods.include?(:sort_params)
      scope.page(page_num).per(page_size)
    end
  end

  def show; end

  def create
    resource_instance.save!
    render :show
  end

  def update
    resource_instance.update!(update_params)
    render :show
  end

  def destroy
    resource_instance.destroy!
    head :ok
  end

  private

  def page_params
    params.permit(:page, :size, :_start, :_end)
  end

  def page_num
    if page_params[:page].present?
      page_params[:page].to_i
    else
      1 + [page_params[:_start].to_i + 1, 1].max / page_size
    end
  end

  DEFAULT_PAGE_SIZE = 10
  VALID_PAGE_SIZE = (1..25).freeze

  def page_size
    requested = requested_page_size
    VALID_PAGE_SIZE.include?(requested) ? requested : DEFAULT_PAGE_SIZE
  end

  def requested_page_size
    if page_params[:size].present?
      page_params[:size].to_i
    else
      page_params[:_end].to_i - page_params[:_start].to_i
    end
  end

  def mutate_collection
    name = "@#{controller_name}"
    instance_variable_set(name, yield(instance_variable_get(name)))
  end

  def resource_instance
    name = "@#{controller_name.singularize}"
    instance_variable_get(name)
  end

  def crud_params
    {}
  end

  def create_params
    crud_params
  end

  def update_params
    crud_params
  end
end
