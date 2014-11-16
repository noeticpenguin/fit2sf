class RksController < InheritedResources::Base

  private

    def rk_params
      params.require(:rk).permit(:authtoken)
    end
end

