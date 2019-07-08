module Coop
  class ClassificationsController < CoopController
    expose :classifications, -> { Classification.parent_classifications.sorted }

    def index
      render json: classifications, each_serializer: ClassificationSerializer
    end
  end
end
