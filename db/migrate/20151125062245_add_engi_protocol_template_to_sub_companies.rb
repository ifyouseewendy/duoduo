class AddEngiProtocolTemplateToSubCompanies < ActiveRecord::Migration
  def change
    add_column :sub_companies, :engi_protocol_template, :text
  end
end
