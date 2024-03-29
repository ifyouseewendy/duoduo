#= require active_admin/base

$(document).on 'ready', ->
  # Clean footer
  $('.footer').empty()

  # Use localized datepicker
  $( "#datepicker" ).datepicker( $.datepicker.regional['zh-CN'] )

  # Add spinner for upload
  $('input[value=上传]').on 'click', (e)->
    $(@).val('正在上传')

  # Confirm on all delete action
  $('a[data-method=delete]').on 'click', ->
    return confirm('请谨慎操作，确定删除？');

  # Individual Income Tax calculate
  $('.iit_form .submit').on 'click', ->
    $.ajax
      url: "/individual_income_taxes/calculate"
      type: 'post'
      dataType: 'json'
      data:
        salary: $('.iit_form #salary').val();
        bonus: $('.iit_form #bonus').val();
      success: (data, textStatus, jqXHR) ->
        $('.iit_form .result').text("应缴税金：" + data['result']).show();

  # Batch Edit Fields
  $('a[data-action=batch_edit], a[data-action=batch_copy]').on 'click', ->
    $('.ui-dialog-title').text('批量修改字段');

    list = $('#dialog_confirm ul')
    list.empty();

    for key,val of $(this).data('inputs')
      id = key.split('_')[0..-2].join('_')
      name = key.split('_')[-1..-1].join()

      if typeof val is 'string'
        list.append("<li><input type='checkbox' class='batch_update_protect_fild_flag' value='Y' id='batch_update_dialog_"+id+"'><label class='batch_edit_label' for='batch_update_dialog_"+id+"'> "+name+"</label><input name='"+id+"' class='' type='text' disabled='disabled'></li>")
      else
        # enum select options
        html = "<li>"
        html += "<input type='checkbox' class='batch_update_protect_fild_flag' value='Y' id='batch_update_dialog_"+id+"'>"
        html += "<label class='batch_edit_label'> #{name}</label>"
        html += "<select name='#{id}' class='' type='' disabled='disabled'>"
        html += "<option selected disabled>请选择</option>"
        for options in val
          html += "<option value='#{options[1]}'>#{options[0]}</option>"
        html += "</select></li>"

        list.append(html)

    $('input.batch_update_protect_fild_flag').on 'click', ->
      input = $(this).siblings('input')
      if input.attr('disabled') == 'disabled'
        input.removeAttr('disabled')
      else
        input.attr('disabled', 'disabled')

      select = $(this).siblings('select')
      if select.attr('disabled') == 'disabled'
        select.removeAttr('disabled')
      else
        select.attr('disabled', 'disabled')

  # Batch Edit Fields
  $('a[data-action=assign_project]').on 'click', ->
    $('.ui-dialog-title').text('分配工程项目');

    list = $('#dialog_confirm ul')
    list.empty();

    for key,val of $(this).data('inputs')
      id = key.split('_')[0..-2].join('_')
      name = key.split('_')[-1..-1].join()

      # enum select options
      html = "<li>"
      html += "<label> #{name}</label>"
      html += "<select name='#{id}' class='' type=''>"
      html += "<option selected disabled>请选择</option>"
      for options in val
        html += "<option value='#{options[1]}'>#{options[0]}</option>"
      html += "</select></li>"

      list.append(html)

  # New project page, auto set nest_index when select customer
  new_project_index = $('#new_engineering_project #engineering_project_engineering_customer_id option[selected=selected]').data('project-index')
  if new_project_index
    $('#new_engineering_project #engineering_project_nest_index').val(new_project_index)

  $('#new_engineering_project #engineering_project_engineering_customer_id').on 'change', ->
    option = $(this).children(":selected")
    index = option.data('project-index')
    if index
      $('#new_engineering_project #engineering_project_nest_index').val(index)

  # Expand index table action width
  $('.expand_table_action_width').closest('.table_actions').css('width', '250px')
  $('.expand_table_action_width_large').closest('.table_actions').css('width', '350px')

  # Write all engineering staffs info into a hidden field
  if $('.engineering_staffs.index .add_projects_link').length > 0
    $.getJSON '/engineering_projects/query_all', (data) =>
      $('.engineering_staffs').append """
        <input type="hidden" class="project_ids_cache">
      """
      stats = []
      $.each data, (idx, ele) ->
        stats.push( [ ele['name'], ele['id'] ] )
      $('.project_ids_cache').data('project-ids', stats)

  # Engineering Staff, add project link
  $('.add_projects_link').on 'click', (e) ->
    e.stopPropagation()
    e.preventDefault()

    columns = {}
    columns['engineering_project_ids'] = $('.project_ids_cache').data('project-ids')

    names = ['工程项目']

    staff_id = $(this).closest('tr').attr('id').split('_')[-1..][0]

    ActiveAdmin.modal_dialog_multiple_select '项目列表', columns, names, 'multiple',
      (inputs)=>
        $.ajax
          url: '/engineering_staffs/' + staff_id + '/add_projects'
          data:
            engineering_project_ids: $('.ui-dialog option:checked').map( (idx, ele) -> return $(ele).val() ).get()
          type: 'post'
          dataType: 'json'
          success: (data, textStatus, jqXHR) ->
            alert( data['message'] )

  # Engineering Staff, remove project link
  $('.remove_projects_link').on 'click', (e) ->
    e.stopPropagation()
    e.preventDefault()

    staff_id = $(this).closest('tr').attr('id').split('_')[-1..][0]

    $.getJSON "/engineering_projects/query_staff?staff_id=#{staff_id}", (data) =>
      columns = []
      names = []
      $.each data, (idx, ele) ->
        columns.push([ele['id'], 'checkbox'])
        names.push( ele['name'] )

      ActiveAdmin.modal_dialog_check_list '项目列表', columns, names,
        (inputs)=>
          $.ajax
            url: '/engineering_staffs/' + staff_id + '/remove_projects'
            data:
              engineering_project_ids: $('.ui-dialog input:checked').map( (idx, ele) -> return $(ele).val() ).get()
            type: 'post'
            dataType: 'json'
            success: (data, textStatus, jqXHR) ->
              alert( data['message'] )
              location.reload()

  # Engineering Project, add staff link
  $('.add_staffs_link').on 'click', (e) ->
    e.stopPropagation()
    e.preventDefault()

    # Show flower
    $(@).empty().html("<i class='fa fa-spinner fa-spin'></i>")

    project_id = $(this).closest('tr').attr('id').split('_')[-1..][0]

    $.getJSON "/engineering_staffs/query_free?project_id=#{project_id}", (data) =>
      stats = []
      $.each data['stat'], (idx, ele) ->
        stats.push( [ ele['name'], ele['id'] ] )

      columns = {}
      columns['engineering_staff_ids'] = stats

      names = ["当前客户<#{data['customer']}>可用员工（#{data['count']}个）"]

      # Hide flower
      $(@).empty().text('添加')

      ActiveAdmin.modal_dialog_project_add_staffs "#{data['display_name']}", columns, names, project_id,
        (inputs)=>
          staff_ids = []
          $('.current_staff_select option:checked').each (idx, ele) ->
            staff_ids.push( $(ele).val() )
          $('.other_staff_select option:checked').each (idx, ele) ->
            staff_ids.push( $(ele).val() )

          $.ajax
            url: '/engineering_projects/' + project_id + '/add_staffs'
            data:
              engineering_staff_ids: staff_ids
            type: 'post'
            dataType: 'json'
            success: (data, textStatus, jqXHR) ->
              alert( data['message'] )

  # Engineering Project, remove staff link
  $('.remove_staffs_link').on 'click', (e) ->
    e.stopPropagation()
    e.preventDefault()

    # Show flower
    $(@).empty().html("<i class='fa fa-spinner fa-spin'></i>")

    project_id = $(this).closest('tr').attr('id').split('_')[-1..][0]

    $.getJSON "/engineering_staffs/query_project?project_id=#{project_id}", (data) =>
      columns = []
      names = []
      $.each data, (idx, ele) ->
        columns.push([ele['id'], 'checkbox'])
        names.push( ele['name'] )

      # Hide flower
      $(@).empty().text('删除')

      ActiveAdmin.modal_dialog_check_list '员工列表', columns, names,
        (inputs)=>
          $.ajax
            url: '/engineering_projects/' + project_id + '/remove_staffs'
            data:
              engineering_staff_ids: $('.ui-dialog input:checked').map( (idx, ele) -> return $(ele).val() ).get()
            type: 'post'
            dataType: 'json'
            success: (data, textStatus, jqXHR) ->
              alert( data['message'] )
              location.reload()

      $('.engineering_projects .unselect_all').on 'click', (e) ->
        e.stopPropagation()
        e.preventDefault()

        $.each $(this).closest('ul').find('li'), (idx, ele) ->
          if idx > 0
            $(ele).find('input').prop('checked', false)

      $('.engineering_projects .select_all').on 'click', (e) ->
        e.stopPropagation()
        e.preventDefault()

        $.each $(this).closest('ul').find('li'), (idx, ele) ->
          if idx > 0
            $(ele).find('input').prop('checked', true)


  # Engineering Project, generate salary table link
  $('.generate_salary_table_link').on 'click', (e) ->
    e.stopPropagation()
    e.preventDefault()

    project_ele = $(this).closest('tr')
    project_id = project_ele.attr('id').split('_')[-1..][0]

    $.getJSON "/engineering_projects/#{project_id}/available_staff_count", (data) =>
      amount = project_ele.find('.col-project_amount').text()

      upper_salary = 3500
      date = project_ele.find('.col-project_start_date').text()
      if date >= "2018-10-01"
        upper_salary = 5000

      need_count = parseInt(amount/upper_salary)
      if need_count * upper_salary < amount
        need_count += 1

      project  =
        id: project_id
        name: project_ele.find('.col-name').text()
        start_date: project_ele.find('.col-project_start_date').text()
        end_date: project_ele.find('.col-project_end_date').text()
        range: project_ele.find('.col-project_range').text()
        amount: amount
        upper_salary: upper_salary
        need_staff_count: need_count
        free_staff_count: data['count'] # 30

      ActiveAdmin.modal_dialog_generate_salary_table project, (inputs)=>
        make_request = true

        li = $("#salary_type_list_#{project['id']}")
        salary_type = li.find('input:checked').val()

        form_data = new FormData
        form_data.append('salary_type', salary_type)

        if inputs['salary_type'] == 'EngineeringNormalSalaryTable'
          if project['free_staff_count'] >= project['need_staff_count']
            form_data.append('need_count', need_count)
          else
            make_request = false

        else if inputs['salary_type'] == 'EngineeringNormalWithTaxSalaryTable'
          form_data.append('salary_file', li.closest('ol').find('.salary_file')[0].files[0])

        else
          form_data.append('salary_url', li.closest('ol').find('.big_item input').val() )

        if make_request
          $.ajax
            url: '/engineering_projects/' + project['id'] + '/generate_salary_table'
            type: 'post'
            data: form_data
            dataType: 'json'
            contentType: false
            processData: false
            success: (data, textStatus, jqXHR) ->
              if data['status'] == 'succeed'
                window.location = data['url']
              else
                alert( data['message'] )

  # Engineering Project, locked status change
  if $('.engineering_projects').length > 0
    $('.col-locked li a').on 'click', (e) ->
      e.stopPropagation()
      e.preventDefault()

      $(@).html("<i class='fa fa-spinner fa-spin'></i>")
      project_id = $(this).closest('tr').attr('id').split('_')[-1..][0]

      $.ajax
        url: "/engineering_projects/#{project_id}/toggle_locked"
        type: 'post'
        dataType: 'json'
        success: (data, textStatus, jqXHR) ->
          alert( data['message'] )
          location.reload()

    # Check project invoices sum
    $('.col-invoices .invoice-valid').closest('td').css('background-color', 'rgba(125, 255, 125, 0.309804)')
    $('.col-invoices .invoice-invalid').closest('td').css('background-color', 'rgba(255, 0, 0, 0.18)')

  # Float thead for all table
  if $('table.index_table').length > 0
    $('table.index_table').floatThead();

  # URLs
  url = window.location.href.toString().split(window.location.host)[1]
  current_path = url.split('?')[0].replace('#', '')
  query_string = url.split('?')[1]


  # Salary Table
  if $('.salary_tables, .guard_salary_tables, .non_full_day_salary_tables').length > 0
    # Check salary table invoices sum
    $('.col-invoices .invoice-valid').closest('td').css('background-color', 'rgba(125, 255, 125, 0.309804)')
    $('.col-invoices .invoice-invalid').closest('td').css('background-color', 'rgba(255, 0, 0, 0.18)')

  # Salary Item
  if $('.salary_items, .non_full_day_salary_items, .guard_salary_items').length > 0

    # Hide download and new button for staff's salary items
    if query_string && query_string.indexOf('normal_staff_id_eq')
      $('.action_item').hide()

    # Insert some br to make it visible
    $('a[data-action=batch_edit]').on 'click', ->
      $('#dialog_confirm').find('input[name=annual_reward]').closest('li').after('<hr>')
      $('#dialog_confirm').find('input[name=pension_company]').closest('li').before('<hr>')
      $('#dialog_confirm').find('input[name=other_company]').closest('li').after('<hr>')

    # Manipulate Insurance Fund
    $('a[data-action=manipulate_insurance_fund]').on 'click', ->
      $('.ui-dialog-title').text('请选择');

      list = $('#dialog_confirm ul')
      list.empty();

      list.append("""
      <li class='control'><a href='#' class='select_all'>全选</a> <a href='#' class='unselect_all'>取消全选</a></li>
      <hr>
      """)

      for key,val of $(this).data('inputs')
        id = key.split('_')[0..-2].join('_')
        name = key.split('_')[-1..-1].join()

        list.append("<li class='flag_list'><input type='checkbox' class='batch_update_protect_fild_flag' checked='checked' name='"+id+"' value='checked'><label> "+name+"</label></br></li>")

      list.append("""
      <hr/>
      <li class='control transfer_to'>
        转向： 
        <input type="radio" name="transfer_to" value="self" class='normal_radio' checked='checked'> 个人
        <input type="radio" name="transfer_to" value="zheqi" class='normal_radio'> 喆琦
      </li>
      """)

      transfer_to = list.find('.transfer_to')
      transfer_to.find('.other_radio').on 'click', ->
        transfer_to.find('.transfer_to_other').show()
      transfer_to.find('.normal_radio').on 'click', ->
        transfer_to.find('.transfer_to_other').hide()

      list.find('.control').css('display', 'block')
      list.find('.flag_list').css('display', 'inline-block').css('width', '300px')

      list.find('.batch_update_protect_fild_flag').on 'click', ->
        if $(@).is(':checked')
          $(@).val('checked')
        else
          $(@).val('')

      list.find('.select_all').on 'click', (e) ->
        e.stopPropagation()
        e.preventDefault()

        $.each $(this).closest('ul').find('.flag_list'), (idx, ele) ->
          $(ele).find('.batch_update_protect_fild_flag').prop('checked', true)
          $(ele).find('.batch_update_protect_fild_flag').val('checked')

      list.find('.unselect_all').on 'click', (e) ->
        e.stopPropagation()
        e.preventDefault()

        $.each $(this).closest('ul').find('.flag_list'), (idx, ele) ->
          $(ele).find('.batch_update_protect_fild_flag').prop('checked', false)
          $(ele).find('.batch_update_protect_fild_flag').val('')


    # Add View
    if query_string && query_string.indexOf("view=proof") != -1
      button_name = '：帐用'
    else if query_string && query_string.indexOf("view=card") != -1
      button_name = '：打卡'
    else
      button_name = '：全部'

    button_query_string_parts = []

    if query_string
      $.each query_string.split('&'), (idx, ele) ->
        console.log(ele)
        if ele.indexOf('view=') == -1
          button_query_string_parts.push ele

    button_query_string = button_query_string_parts.join('&')

    html =  """
            <div class='views_selector dropdown_menu'>
              <a class='dropdown_menu_button' href='#'>视图#{button_name}</a>
              <div class='dropdown_menu_list_wrapper' style='display: none;'><div class='dropdown_menu_nipple'></div>
                <ul class='dropdown_menu_list'>
                  <li><a href='#{current_path}?#{button_query_string}'>全部</a></li>
                  <li><a href='#{current_path}?#{button_query_string}&view=proof'>帐用</a></li>
                  <li><a href='#{current_path}?#{button_query_string}&view=card'>打卡</a></li>
                </ul>
              </div>
            </div>
            """

    $('.table_tools .batch_actions_selector').after(html)

    $('.views_selector .dropdown_menu_button').on 'click', (e) ->
      e.stopPropagation()
      e.preventDefault()
      list = $(@).next('.dropdown_menu_list_wrapper')
      if list.css('display') == 'none'
        list.css('top', '174px')
        list.find('.dropdown_menu_nipple').css('left', '20px')
        list.show();
      else
        list.hide();

    $('.views_selector .custom a').on 'click', (e) ->
      e.stopPropagation()
      e.preventDefault()
      $('.views_selector .dropdown_menu_list_wrapper').hide();

      columns = {}
      names = []
      $('#index_table_salary_items th')[1..-2].each ->
        col = $(this).attr('class').split(' ')[-1..][0].split('-')[1..-1]
        name = $(this).find('a').text()
        columns[col] = 'checkbox'
        names.push(name)

      ActiveAdmin.modal_dialog_modified '请选择展示字段', columns, names,
        (inputs)=>
          columns = []
          for key,val of inputs
            columns.push key

          window.location = "#{current_path}?view=custom&columns=#{columns.join('-')}"

    $(document).on 'click', ->
      $('.views_selector .dropdown_menu_list_wrapper').hide()

    parts = current_path.split('/')
    if parts[1] == 'salary_tables' or parts[1] == 'non_full_day_salary_tables' or parts[1] == 'guard_salary_tables'
      salary_table_id = parts[2]
      salary_table_path = parts[1]

      # Add progress bar
      $.ajax
        url: "/#{salary_table_path}/#{salary_table_id}/audition_state"
        success: (data, textStatus, jqXHR) =>
          html = """
            <div class="progress-wrap">
              <table class="progress-bar">
          """
          $.each data['data'], (idx, ele) ->
            if ele['value'] == null
              if ele['hide']
                value = ''
              else
                value = "<a href='#' class='activate'>确定</a>"
            else
              value = "#{ele['value']}"
            html += """
              <tr>
                <th>#{ele['display']}：</th>
                <td class="#{ele['key']}">#{value}</td>
              </tr>
            """
          $('.table_tools').append(html)

          $('.progress-bar .activate').on 'click', (e)->
            e.stopPropagation()
            e.preventDefault()
            state = $(@).closest('td').attr('class')
            $.ajax
              url: "/#{salary_table_path}/#{salary_table_id}/toggle_audition_state"
              data:
                state: state
              success: (data, textStatus, jqXHR) ->
                alert( data['message'] )
                location.reload()

      # Editable remark
      panel_contents = $('.index_as_table .panel .panel_contents')
      edit_div = """
        <div class='edit_div'>
          <a href='#' class='edit'>编辑</a>
          <a href='#' class='cancel'>取消</a>&nbsp
          <a href='#' class='submit'>保存</a>
        </div>
      """
      $('.index_as_table .panel').append(edit_div)

      $('.index_as_table .panel .edit_div .cancel').hide()
      $('.index_as_table .panel .edit_div .submit').hide()

      old_content = null

      $('.index_as_table .panel .edit').on 'click', (e) ->
        e.stopPropagation()
        e.preventDefault()

        old_content = panel_contents.text()
        panel_contents.empty().append("<textarea rows='5'>#{old_content}</textarea>")

        $('.index_as_table .panel .edit_div .edit').hide()
        $('.index_as_table .panel .edit_div .cancel').show()
        $('.index_as_table .panel .edit_div .submit').show()

      $('.index_as_table .panel .cancel').on 'click', (e) ->
        e.stopPropagation()
        e.preventDefault()
        content = panel_contents.empty().text(old_content)
        $('.index_as_table .panel .edit_div .edit').show()
        $('.index_as_table .panel .edit_div .cancel').hide()
        $('.index_as_table .panel .edit_div .submit').hide()

      $('.index_as_table .panel .submit').on 'click', (e) ->
        new_content = panel_contents.find('textarea').val()
        $.ajax
          url: "/#{salary_table_path}/#{salary_table_id}/update_remark"
          data:
            remark: new_content
          success: (data, textStatus, jqXHR) =>
            panel_contents.empty().text(new_content)
            $('.index_as_table .panel .edit_div .edit').show()
            $('.index_as_table .panel .edit_div .cancel').hide()
            $('.index_as_table .panel .edit_div .submit').hide()
            alert( data['message'] )


  # Export XLSX
  export_path = "#{current_path}/export_xlsx?#{query_string}"
  html =  """
          <span>下载:</span>
          <a href="#{export_path}">XLSX</a>
          """
  $('body .download_links').empty().append(html)

  $('body .download_links a').on 'click', (e) ->
    if $('.index_table .selected').length > 0
      e.stopPropagation()
      e.preventDefault()
      if window.confirm("下载已选中条目？")
        selected = []
        $('.index_table .selected').each ->
          selected.push($(this).attr('id').split('_')[-1..][0])
        window.location = "#{export_path}&selected=#{selected.join('-')}"
    else
      window.location = $(@).val('href')

  $('.admin_users .download_links').hide();
  $('.audition_items .download_links').hide();
  $('.comments .download_links').hide();
  $('.engineering_salary_tables .download_links').hide();
  $('.salary_tables .download_links').hide();
  $('.non_full_day_salary_tables .download_links').hide();
  $('.guard_salary_tables .download_links').hide();
  $('.invoice_settings .download_links').hide();

  # Comments
  $('.comments .table_tools').hide();

  # Admin User delete
  $('.admin_users .admin_user_delete').on 'click', (e) ->
    e.stopPropagation()
    e.preventDefault()

    if confirm("确认彻底删除员工？")
      user_id = $(this).closest('tr').attr('id').split('_')[-1..][0]
      $.ajax
        url: "/admin_users/#{user_id}"
        type: 'delete'
        success: (data, textStatus, jqXHR) ->
          if data['status'] == 'succeed'
            window.location = data['url']
          else
            alert( data['message'] )

  # Normal Staff sidebar
  current_contract = $('body.normal_staffs .current_contract')
  current_contract.css("padding-right", "10px")
  current_contract.closest('li').append("<span class='status_tag active ok'>当前合同</span>")

  # Import Introduction
  $('.normal_corporation .import_guide ol').append('<li>3. 字段"管理费收取方式"的有效值为：每人固定比例（应发工资），每人固定比例（应发工资+单位缴费），每人固定金额</li>')

  # Invoice Settings
  if $('.invoice_settings').length > 0
    set_category = (option) ->
      category = option.data('category')
      $("#invoice_setting_category_#{category}").prop('checked', true)
      code = option.data('code')
      $('#invoice_setting_code').val( code )

    default_option = $('#invoice_setting_sub_company_id option:selected')
    if default_option
      set_category( default_option )

    $('#invoice_setting_sub_company_id').on 'change', ->
      set_category( $(@).children(":selected") )

  # Invoices
  if $('.invoices').length > 0
    # Hide batch destroy action
    $('.batch_action[data-action=destroy]').closest('li').hide()

    set_code_and_encoding = (choice) ->
      category = choice.find('input').val()

      label = choice.find('label')
      label.append("<i class='fa fa-spinner fa-spin'></i>")

      sub_company_id = $('#invoice_sub_company_id option:selected').val()

      $.ajax
        url: '/invoice_settings/available'
        data:
          category: category
          sub_company_id: sub_company_id
        dataType: 'json'
        success: (data, textStatus, jqXHR) =>
          label.find('i').remove()

          label = choice.find('label')
          label.find('span').remove()

          if data['status'] == 'ok'
            $('#invoice_code').prop('disabled', false)
            $('#invoice_code').val( data['data']['code'] )
            $('#invoice_encoding').prop('disabled', false)
            $('#invoice_encoding').val( data['data']['encoding'] )
            $('#invoice_invoice_setting_id').val( data['data']['invoice_setting_id'] )
          else
            label.append("<span style='color:red'> #{data['message']}</span>")
            $('#invoice_code').prop('disabled', true).val('无可用发票')
            $('#invoice_encoding').prop('disabled', true).val('')

    set_category = (option) ->
      category = option.data('category')
      $("#invoice_category_#{category}").prop('checked', true)
      set_code_and_encoding( $("#invoice_category_#{category}").closest('.choice') )

    load_projects = ->
      scope = $('#invoice_scope_input input:checked').val()
      obj_name = $('#invoice_contact_input option:selected').val()

      input = $('#invoice_project_input')
      input.append("<i class='fa fa-spinner fa-spin'></i>")

      select = $('#invoice_project_id')
      select.empty()

      if scope == 'engineer'
        $.ajax
          url: '/engineering_projects/query_by_customer'
          data:
            customer_name: obj_name
          dataType: 'json'
          success: (data, textStatus, jqXHR) =>
            input.find('i').remove()

            if data['status'] == 'ok'

              names = data['data']['names']
              ids = data['data']['ids']
              types = data['data']['types']
              $.each names, (idx, ele) ->
                select.append("<option value='#{ids[idx]}' data-type='#{types[idx]}'>#{ele}</option>")

              $('#invoice_project_type').val('EngineeringProject')
      else
        $.ajax
          url: '/normal_corporations/query_salary_tables'
          data:
            name: obj_name
          dataType: 'json'
          success: (data, textStatus, jqXHR) =>
            input.find('i').remove()

            if data['status'] == 'ok'

              names = data['data']['names']
              ids = data['data']['ids']
              types = data['data']['types']
              $.each names, (idx, ele) ->
                select.append("<option value='#{ids[idx]}' data-type='#{types[idx]}'>#{ele}</option>")

              $('#invoice_project_type').val(types[0])

    set_invoice_project_type = ->
      $('#invoice_project_id').on 'change', ->
        type = $(@).children(':selected').data('type')
        $('#invoice_project_type').val(type)

    set_contact = (choice) ->
      scope = choice.find('input').val()
      sub_company_id = $('#invoice_sub_company_id option:selected').val()

      label = choice.find('label')
      label.append("<i class='fa fa-spinner fa-spin'></i>")

      if scope == 'engineer'
        $.ajax
          url: '/engineering_customers/display'
          dataType: 'json'
          success: (data, textStatus, jqXHR) =>
            label.find('i').remove()

            if data['status'] == 'ok'
              contact = $('#invoice_contact')
              contact.empty()

              names = data['data']['names']
              full_names = data['data']['full_names']
              $.each names, (idx, ele) ->
                contact.append("<option data-full-name=#{full_names[idx]} value='#{ele}'>#{ele}</option>")
              $('#invoice_payer').val( full_names[0] )

              load_projects()
      else
        $.ajax
          url: '/normal_corporations/display'
          data:
            sub_company_id: sub_company_id
          dataType: 'json'
          success: (data, textStatus, jqXHR) =>
            label.find('i').remove()

            if data['status'] == 'ok'
              contact = $('#invoice_contact')
              contact.empty()

              names = data['data']['names']
              full_names = data['data']['full_names']
              $.each names, (idx, ele) ->
                contact.append("<option data-full-name=#{full_names[idx]} value='#{ele}'>#{ele}</option>")
              $('#invoice_payer').val( full_names[0] )

              load_projects()

    set_payer = (option) ->
      $('#invoice_payer').val( option.data('full-name') )

    # Change sub_company
    $('#invoice_sub_company_id').on 'change', ->
      set_category( $(@).children(":selected") )
      set_contact( $('#invoice_scope_input input:checked').closest('.choice') )

    # Change category
    $('#invoice_category_input input').on 'change', ->
      set_code_and_encoding( $(@).closest('.choice') )

    # Change scope
    $('#invoice_scope_input input').on 'change', ->
      set_contact( $(@).closest('.choice') )

    # Change contact
    $('#invoice_contact').on 'change', ->
      set_payer( $(@).children(":selected") )
      load_projects()

    # Change project
    set_invoice_project_type()

    if $('.invoices.new').length > 0
      # Set default category
      default_option = $('#invoice_sub_company_id option:selected')
      if default_option.length > 0
        set_category( default_option )

      # Set default scope
      default_scope = $('#invoice_scope_input input:checked').closest('.choice')
      if default_scope
        set_contact( $(default_scope) )

    if $('.invoices.edit').length > 0
      $('#invoice_contact_input').append(" <a href='#' class='load_contacts'>加载列表</a>")

      $('#invoice_contact_input .load_contacts').on 'click', (e)->
        e.stopPropagation()
        e.preventDefault()
        set_contact( $('#invoice_scope_input input:checked').closest('.choice') )

    # Change amount and admin_amount to cal sum
    $('#invoice_amount').on 'change', ->
      sum = 0
      amount_val = $('#invoice_amount').val()
      if amount_val
        sum += parseFloat(amount_val)
      admin_val = $('#invoice_admin_amount').val()
      if admin_val
        sum += parseFloat(admin_val)
      $('#invoice_total_amount').val(sum)

    $('#invoice_admin_amount').on 'change', ->
      sum = 0
      amount_val = $('#invoice_amount').val()
      if amount_val
        sum += parseFloat(amount_val)
      admin_val = $('#invoice_admin_amount').val()
      if admin_val
        sum += parseFloat(admin_val)
      $('#invoice_total_amount').val(sum)

    # Batch action
    $('#invoice_batch_count_input').hide()
    $('#invoice_batch_file_input').hide()
    $('#invoice_batch_create').on 'change', ->
      if $(@).prop('checked') == true
        $('#invoice_batch_count_input').show()
        $('#invoice_batch_file_input').show()
      else
        $('#invoice_batch_count_input').hide()
        $('#invoice_batch_file_input').hide()

    # Forbid multiple submits
    $('.new #invoice_submit_action input').on 'click', ->
      $(@).prop('disabled', true).val('正在新建')
      $(@).closest('form').submit()

  if $('.admin_users').length > 0
    $('.edit .actions .cancel').hide()

# Cutsom Modal used in Custom View
ActiveAdmin.modal_dialog_modified = (message, inputs, display_names, callback)->
  html = """<form id="dialog_confirm" title="#{message}"><ul>"""
  idx = 0
  for name, type of inputs
    if /^(datepicker|checkbox|text)$/.test type
      wrapper = 'input'
    else if type is 'textarea'
      wrapper = 'textarea'
    else if $.isArray type
      [wrapper, elem, opts, type] = ['select', 'option', type, '']
    else
      throw new Error "Unsupported input type: {#{name}: #{type}}"

    klass = if type is 'datepicker' then type else ''
    html += """<li>
      <#{wrapper} name="#{name}" class="#{klass}" type="#{type}" checked='checked'>""" +
        (if opts then (
          for v in opts
            $elem = $("<#{elem}/>")
            if $.isArray v
              $elem.text(v[0]).val(v[1])
            else
              $elem.text(v)
            $elem.wrap('<div>').parent().html()
        ).join '' else '') +
      "</#{wrapper}>" +
      "<label> #{display_names[idx]}</label>"
    "</li>"
    [wrapper, elem, opts, type, klass] = [] # unset any temporary variables

    idx += 1

  html += "</ul></form>"

  form = $(html).appendTo('body')
  $('body').trigger 'modal_dialog:before_open', [form]

  form.dialog
    modal: true
    open: (event, ui) ->
      $('body').trigger 'modal_dialog:after_open', [form]
    dialogClass: 'active_admin_dialog'
    buttons:
      OK: ->
        callback $(@).serializeObject()
        $(@).dialog('close')
      Cancel: ->
        $(@).dialog('close').remove()

# Cutsom Modal used in Index custom actions
ActiveAdmin.modal_dialog_multiple_select = (message, inputs, display_names, multiple, callback)->
  html = """<form id="dialog_confirm" title="#{message}"><ul>"""
  idx = 0
  for name, type of inputs
    if $.isArray type
      [wrapper, elem, opts, type] = ['select', 'option', type, '']
    else
      throw new Error "Unsupported input type: {#{name}: #{type}}"

    klass = if type is 'datepicker' then type else ''
    html += """<li>
      <label style='float:left'> #{display_names[idx]}</label>
      <#{wrapper} name="#{name}" class="#{klass}" type="#{type}" checked='checked' #{multiple} style='height:200px;width:100px;'>""" +
        "<option selected disabled>请选择</option>" +
        (if opts then (
          for v in opts
            $elem = $("<#{elem}/>")
            if $.isArray v
              $elem.text(v[0]).val(v[1])
            else
              $elem.text(v)
            $elem.wrap('<div>').parent().html()
        ).join '' else '') +
      "</#{wrapper}>" +
    "</li>"
    [wrapper, elem, opts, type, klass] = [] # unset any temporary variables

    idx += 1

  html += "</ul></form>"

  form = $(html).appendTo('body')
  $('body').trigger 'modal_dialog:before_open', [form]

  form.dialog
    modal: true
    open: (event, ui) ->
      $('body').trigger 'modal_dialog:after_open', [form]
      $('.active_admin_dialog').css('width', '600px').css('left', '400px')
    dialogClass: 'active_admin_dialog'
    buttons:
      OK: ->
        callback $(@).serializeObject()
        $(@).find('option:checked').prop('selected', false)
        $(@).dialog('close')
      Cancel: ->
        $(@).find('option:checked').prop('selected', false)
        $(@).dialog('close').remove()

ActiveAdmin.modal_dialog_check_list = (message, inputs, display_names, callback)->
  html = """<form id="dialog_confirm" title="#{message}"><ul>"""
  html += """
  <li><a href='#' class='select_all'>全选</a> <a href='#' class='unselect_all'>取消全选</a></li>
  """

  idx = 0
  $.each inputs, (id, column) ->
    name = column[0]
    type = column[1]
    console.log(name)
    console.log(type)
    if /^(datepicker|checkbox|text)$/.test type
      wrapper = 'input'
    else
      throw new Error "Unsupported input type: {#{name}: #{type}}"

    klass = if type is 'datepicker' then type else ''
    html += """<li>
      <#{wrapper} name="#{name}" value="#{name}" class="#{klass}" type="#{type}" checked='checked'>""" +
        (if opts then (
          for v in opts
            $elem = $("<#{elem}/>")
            if $.isArray v
              $elem.text(v[0]).val(v[1])
            else
              $elem.text(v)
            $elem.wrap('<div>').parent().html()
        ).join '' else '') +
      "</#{wrapper}>" +
      "<label> #{display_names[idx]}</label>"
    "</li>"
    [wrapper, elem, opts, type, klass] = [] # unset any temporary variables

    idx += 1

  html += "</ul></form>"

  form = $(html).appendTo('body')
  $('body').trigger 'modal_dialog:before_open', [form]

  form.dialog
    modal: true
    open: (event, ui) ->
      $('body').trigger 'modal_dialog:after_open', [form]
    dialogClass: 'active_admin_dialog'
    buttons:
      OK: ->
        callback $(@).serializeObject()
        $(@).find('option:checked').prop('selected', false)
        $(@).dialog('close')
      Cancel: ->
        $(@).find('option:checked').prop('selected', false)
        $(@).dialog('close').remove()

ActiveAdmin.modal_dialog_project_add_staffs = (message, inputs, display_names, project_id, callback)->
  html = """<form id="dialog_confirm" title="#{message}"><ul>"""
  idx = 0
  for name, type of inputs
    if $.isArray type
      [wrapper, elem, opts, type] = ['select', 'option', type, '']
    else
      throw new Error "Unsupported input type: {#{name}: #{type}}"

    html += """
      <li style='height:180px'>
        <label style='display:block; margin-bottom:10px'>#{display_names[idx]}</label>
        <select name="#{name}" class="current_staff_select" type="" checked='checked' multiple style='height:150px;width:300px;'>
          <option selected disabled>请选择</option>
    """

    for v,i in opts
      html += "<option value='#{v[1]}'>#{i+1} - #{v[0]}</option>"

    html += "</select></li>"

    [wrapper, elem, opts, type, klass] = [] # unset any temporary variables

    idx += 1

  # Other customers
  html += """
    <li style='height:180px'>
      <label style='float:left; margin-bottom:10px'>其他客户可用员工 <a href='#' class='load_select'>(加载)</a></label>
      <select name="" class="other_customer_select" type="" checked='checked' style='display:none;float:left;margin-right:10px;'>
        <option class='default_option' disabled>请选择</option>
      </select>
      <select name '' class='other_staff_select' checked='checked' multiple style='display:none;height:150px;width:300px'>
        <option disabled>请选择</option>
      </select>
    </li>
  """

  html += "</ul></form>"

  form = $(html).appendTo('body')
  $('body').trigger 'modal_dialog:before_open', [form]

  $('.load_select').on 'click', (e)->
    e.stopPropagation()
    e.preventDefault()
    select = $('.other_customer_select')

    $.getJSON "/engineering_customers/other_customers?project_id=#{project_id}", (data) =>
      $.each data, (idx, ele) =>
        select.append """
          <option class='other_customer_option' value="#{ele['id']}">#{ele['name']}</option>
        """
      select.data('loaded', true)
      select.show()

    select.on 'change', ->
      staff_select = $('.other_staff_select')
      staff_select.empty().append """
        <option disabled>请选择</option>
      """
      customer_id = $(this).val()
      $.getJSON "/engineering_customers/" + customer_id + "/free_staffs?project_id=#{project_id}", (data) =>
        $.each data, (idx, ele) ->
          staff_select.append """
            <option value="#{ele['id']}">#{idx} - #{ele['name']}</option>
          """
        staff_select.show()

  form.dialog
    modal: true
    open: (event, ui) ->
      $('body').trigger 'modal_dialog:after_open', [form]
      $('.active_admin_dialog').css('width', '600px').css('left', '400px')
    dialogClass: 'active_admin_dialog'
    buttons:
      OK: ->
        callback $(@).serializeObject()
        $('.current_staff_select option:checked').prop('selected', false)
        $('.other_staff_select option:checked').prop('selected', false)
        $(@).dialog('close')
      Cancel: ->
        $(@).find('option:checked').prop('selected', false)
        $('.current_staff_select option:checked').prop('selected', false)
        $('.other_staff_select option:checked').prop('selected', false)
        $(@).dialog('close').remove()

ActiveAdmin.modal_dialog_generate_salary_table = (data, callback)->
  html = """
    <form novalidate="novalidate" class="formtastic" id="dialog_confirm" title="生成工资表">
    <fieldset class="inputs">
      <ol>
        <li id="salary_type_list_#{data['id']}" class='modal_li'>
          <label>工资表类型</label>
          <input class='salary_type_check' type="radio" name="salary_type" value="EngineeringNormalSalaryTable" checked> 基础</input>
          <input class='salary_type_check' type="radio" name="salary_type" value="EngineeringNormalWithTaxSalaryTable"> 基础（带个税）</input>
          <input class='salary_type_check' type="radio" name="salary_type" value="EngineeringBigTableSalaryTable"> 大表</input>
        </li>
        <li class='normal_with_tax_item' style='display:none'>
          <label>请上传 xlsx 文件</label>
          <input class='salary_file' type='file' name='salary_file' value=''></input>
        </li>
        <li class='big_item' style='display:none'>
          <label>请输入大表链接</label>
          <input class='salary_url' type='text' name='salary_url' value=''></input>
        </li>
        <li class='normal_item'>
          <label>项目名称</label>
          <span>#{data['name']}</span>
        </li>
        <li class='normal_item'>
          <label>起止时间</label>
          <span>#{data['start_date']} ~ #{data['end_date']}</span>
        </li>
        <li class='normal_item'>
          <label>工作量</label>
          <span>#{data['range']}</span>
        </li>
        <li class='normal_item'>
          <label>劳务费</label>
          <span>#{data['amount']}</span>
        </li>
        <li class='normal_item'>
          <label>员工工资上限</label>
          <span>#{data['upper_salary']}</span>
        </li>
        <li class='normal_item'>
          <label>需提供员工数</label>
          <span>#{data['need_staff_count']}</span>
        </li>
        <li class='normal_item'>
          <label>可用员工数</label>
          <span>#{data['free_staff_count']}</span>
        </li>
  """

  if data['free_staff_count'] >= data['need_staff_count']
    html += """
    """
  else
    html += """
      <li class='normal_item'>
        <ul>
          <li><b>建议如下操作后重新进入此页面</b></li>
          <li>调整项目起止日期与工作量，请至 <a href='/engineering_projects/#{data["id"]}/edit'>编辑</a> 页面</li>
          <li>请求客户提供更多员工，请至 <a href='/engineering_staffs/import_new'>导入员工</a> 页面</li>
          <li>从其他客户借入员工，请关闭后选择 <b>添加员工</b> 按钮</li>
        </ul>
      </li>
    """

  html += """
        </ol>
      </fieldset>
    </form>
  """

  form = $(html).appendTo('body')
  $('body').trigger 'modal_dialog:before_open', [form]

  form.dialog
    modal: true
    open: (event, ui) ->
      $('body').trigger 'modal_dialog:after_open', [form]
      $('.active_admin_dialog').css('width', '600px').css('left', '400px').css('max-height', '700px').css('top', '80px')
      $(".salary_type_check").on 'click', ->
        ol = $(this).closest('ol')
        if $(this).val() == 'EngineeringNormalSalaryTable'
          ol.find('.normal_with_tax_item').hide()
          ol.find('.normal_item').show()
          ol.find('.big_item').hide()
        else if $(this).val() == 'EngineeringNormalWithTaxSalaryTable'
          ol.find('.normal_with_tax_item').show()
          ol.find('.normal_item').hide()
          ol.find('.big_item').hide()
        else
          ol.find('.normal_with_tax_item').hide()
          ol.find('.normal_item').hide()
          ol.find('.big_item').show()
    dialogClass: 'active_admin_dialog'
    buttons:
      OK: ->
        callback $(@).serializeObject()
        $(@).dialog('close')
      Cancel: ->
        $(@).find('option:checked').prop('selected', false)
        $(@).dialog('close').remove()
