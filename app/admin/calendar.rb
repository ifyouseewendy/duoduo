ActiveAdmin.register_page "Calendar" do
  content do
    para "Hello World"

    table do
      thead do
        tr do
          %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].each &method(:th)
        end
      end
      tbody do
        # ...
      end
    end
  end

  page_action :add_event, method: :post do
    # ...
    redirect_to calendar_path, notice: "Your event was added"
  end

  action_item :add do
    link_to "Add Event", calendar_add_event_path, method: :post
  end
end
