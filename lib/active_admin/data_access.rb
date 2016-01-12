module ActiveAdmin
  class ResourceController
    module DataAccess
      def apply_sorting(chain)
        params[:order] ||= active_admin_config.sort_order

        orders = []
        params[:order].present? && params[:order].split(/\s*,\s*/).each do |fragment|
          fragment =~ /^([\w\_\.]+)_(desc|asc)$/
          column = $1
          order  = $2
          table  = active_admin_config.resource_column_names.include?(column) ? active_admin_config.resource_table_name : nil
          table_column = (column =~ /\./) ? column :
            [table, active_admin_config.resource_quoted_column_name(column)].compact.join(".")

          orders << "#{table_column} #{order}"
        end

        if orders.empty?
          chain
        else
          chain.reorder(orders.shift).order(orders)
        end
      end
    end
  end
end
