module ImportDemo
  def self.included(base)
    base.instance_eval do
      collection_action :import_demo do
        model = controller_name.classify.constantize
        data = \
          CSV.generate encoding: 'GBK' do |csv|
            csv << [I18n.t("misc.import_demo.notice")]
            csv << model.ordered_columns.map{|col| model.human_attribute_name(col) }
          end
        send_data \
          data,
          :filename => I18n.t("activerecord.models.#{model.to_s.underscore}") + " - " + I18n.t("misc.import_demo.name") + '.csv'
      end
    end
  end
end
