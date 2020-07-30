module Api
  module V1
    class SearchController < ApplicationController
      skip_before_action :verify_authenticity_token

      def search
        if params[:name]
          search_name
        elsif params[:description]
          search_description
        # Repeat the structure above and add corresponding methods to add more search routes
        else
          render json: {status: 'SUCCESS', message: "Please provide a valid search parameter"}, status: :ok
        end
      end

      private

      def search_name
        name = params[:name]
        result = build_results("Project School Name", name)

        if result.empty?
          render json: {status: 'SUCCESS', message: "Could not find Project with name #{name}", data: result}, status: :ok
        else
          render json: {status: 'SUCCESS', message: "Found Project with name #{name}", data: result}, status: :ok
        end
      end

      def search_description
        description = params[:description]
        result = build_results("Project Description", description)

        if result.empty?
          render json: {status: 'SUCCESS', message: "Could not find Project with description #{description}", data: result}, status: :ok
        else
          render json: {status: 'SUCCESS', message: "Found Project with description #{description}", data: result}, status: :ok
        end
      end

      def build_results(key, value)
        data = get_data()
        result = []
        data.each do |project|
          if project[key] == value and filter(project)
            result.push(project)
          end
        end

        return paginate(result)
      end

      def filter(project)
        if params[:filters].has_key?("Project Phase Actual Start Date")
          if project["Project Phase Actual Start Date"] != params[:filters]["Project Phase Actual Start Date"]
            return false
          end
        end

        if params[:filters].has_key?("Project Phase Planned End Date")
          if project["Project Phase Planned End Date"] != params[:filters]["Project Phase Planned End Date"]
            return false
          end
        end

        # Repeat the structure above to add more filters

        return true
      end

      def paginate(result)
        paginated_result = []
        if params.has_key?(:page_size)
          page_size = params[:page_size]
          if params.has_key?(:page)
            page = params[:page]
            offset = page_size * (page - 1)
            paginated_result = result[offset, page_size]
          else
            page = 1
            paginated_result = result[0, page_size]
          end

          total_pages = (result.length / page_size.to_f).ceil
          paginated_result.push({
            "page_size": page_size,
            "page": page,
            "total_results": result.length,
            "total_pages": total_pages
            })
        else
          return result
        end
      end

      def get_data
        file = File.read("app/assets/dataset.json")
        data = JSON.parse(file)
      end
    end
  end
end
