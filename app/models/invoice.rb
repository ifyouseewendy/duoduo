class Invoice < ActiveRecord::Base
  belongs_to :invoicable, polymorphic: true

  class << self
    def ordered_columns(without_base_keys: false, without_foreign_keys: false)
      names = column_names.map(&:to_sym)

      # Fields added by later migration
      polyfill = [:refund_bank, :refund_account]
      names -= polyfill
      idx = names.index(:refund_person) + 1
      names.insert(idx, *polyfill)

      names -= %i(id created_at updated_at) if without_base_keys
      names -= %i(invoicable_id invoicable_type) if without_foreign_keys

      names
    end

    def export_xlsx(options: {})
      names = [self.model_name.human, self.invoicable.name, Time.stamp]
      filename = "#{names.join('_')}.xlsx"
      filepath = EXPORT_PATH.join filename

      st = SalaryTable.find(options[:salary_table_id])
      collection = st.invoices
      collection = collection.where(id: options[:selected]) if options[:selected].present?

      columns = columns_based_on(options: options)

      Axlsx::Package.new do |p|
        p.workbook.add_worksheet(name: name) do |sheet|
          sheet.add_row columns.map{|col| self.human_attribute_name(col)}

          collection.each do |item|
             stats = \
              columns.map do |col|
                item.send(col)
             end
             sheet.add_row stats
          end
        end
        p.serialize(filepath.to_s)
      end

      filepath
    end

    def columns_based_on(options: {})
      if options[:columns].present?
        options[:columns].map(&:to_sym)
      else
        ordered_columns(without_foreign_keys: true)
      end
    end
  end

end
