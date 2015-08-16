module ImportDemo
  def self.included(base)
    base.instance_eval do
      collection_action :import_demo do
        model = controller_name.classify
        data = \
          CSV.generate encoding: 'GBK' do |csv|
            csv << [I18n.t("misc.import_demo.notice")]
            csv << model.constantize.column_names - %w(id created_at updated_at)
          end
        send_data \
          data,
          :filename => I18n.t("activerecord.models.#{model.underscore}") + " - " + I18n.t("misc.import_demo.name") + '.csv'
      end
    end
  end
end
