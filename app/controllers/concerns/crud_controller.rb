module CrudController
  extend ActiveSupport::Concern

  PER_PAGE = 20.freeze

  def index
    paginate json: paginated_resources
  end

  def show
    render json: resource
  end

  def create
    if created?
      create_success
    else
      create_failure
    end
  end

  def update
    if updated?
      update_success
    else
      update_failure
    end
  end

  def destroy
    if destroyed?
      render status: :ok, json: {}
    else
      destroy_failure
    end
  end

  private

  def resource;end

  def resources;end

  def resource_key
    resource.model_name.param_key
  end

  def searched_resources
    resources.search(params.fetch(:search, ''))
  end

  def paginated_resources
    paginate sorted_resources, { page: params[:page], per_page: PER_PAGE }
  end

  # create SortableController
  def default_sort_scope
    searched_resources
  end

  def sort_column
    @sort_column ||= (params_sort_column || default_sort_column)
  end

  def sort_direction
    @sort_direction ||= (params_sort_direction || default_sort_direction)
  end

  def sorted_resources
    default_sort_scope.sorted(sort_column, sort_direction)
  end

  def params_sort_column
    params[:sort_column].present? && params[:sort_column]
  end

  def params_sort_direction
    params[:sort_direction].present? && params[:sort_direction]
  end

  def default_sort_column
    resource.class.try(:default_sort_column)
  end

  def default_sort_direction
    resource.class.try(:default_sort_direction)
  end


  # Create BaseController
  def created?
    resource.save
  end

  def updated?
    resource.update(send("#{resource_key}_params"))
  end

  def destroyed?
    resource.destroy
  end

  def create_success
    render status: :created, json: { "#{resource_key}": resource }
  end

  def create_failure
    failure_render
  end

  def update_success
    render status: :ok, json: { "#{resource_key}": resource }
  end

  def update_failure
    failure_render
  end

  def destroy_failure
    failure_render
  end

  def failure_render
    render status: :unprocessable_entity, json: { errors: failure_errors }
  end

  def failure_errors
    resource.errors_as_json
  end
end
