#= require active_admin/base

$(document).on 'ready', ->
  # Clean footer
  $('.footer').empty()

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
  $('a[data-action=batch_edit]').on 'click', ->
    $('.ui-dialog-title').text('批量修改字段');

    list = $('#dialog_confirm ul')
    list.empty();

    for key,val of $(this).data('inputs')
      id = key.split('_')[0..-2].join('_')
      name = key.split('_')[-1..-1].join()

      if typeof val is 'string'
        list.append("<li><input type='checkbox' class='batch_update_protect_fild_flag' value='Y' id='batch_update_dialog_"+id+"'><label for='batch_update_dialog_"+id+"'> "+name+"</label></br><input name='"+id+"' class='' type='text' disabled='disabled'></li>")
      else
        # enum select options
        html = "<li>"
        html += "<input type='checkbox' class='batch_update_protect_fild_flag' value='Y' id='batch_update_dialog_"+id+"'>"
        html += "<label> #{name}</label>"
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

  # Write all engineering staffs info into a hidden field
  $.getJSON '/engineering_projects/query_all', (data) =>
    $('.engineering_staffs').append """
      <input type="hidden" class="project_ids_cache">
    """
    stats = []
    $.each data, (idx, ele) ->
      stats.push( [ ele['name'], ele['id'] ] )
    $('.project_ids_cache').data('project-ids', stats)

  # Expand index table action width
  $('.expand_table_action_width').closest('.table_actions').css('width', '250px')
  $('.expand_table_action_width_large').closest('.table_actions').css('width', '300px')

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
      columns = {}
      names = []
      $.each data, (idx, ele) ->
        columns[ele['id']] = 'checkbox'
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

    project_id = $(this).closest('tr').attr('id').split('_')[-1..][0]

    $.getJSON "/engineering_staffs/query_free?project_id=#{project_id}", (data) =>
      stats = []
      $.each data['stat'], (idx, ele) ->
        stats.push( [ ele['name'], ele['id'] ] )

      columns = {}
      columns['engineering_staff_ids'] = stats

      names = ["当前客户<#{data['customer']}>下可用员工"]

      ActiveAdmin.modal_dialog_project_add_staffs "可用员工列表（#{data['range_output']}）", columns, names, project_id,
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

    project_id = $(this).closest('tr').attr('id').split('_')[-1..][0]

    $.getJSON "/engineering_staffs/query_project?project_id=#{project_id}", (data) =>
      columns = {}
      names = []
      $.each data, (idx, ele) ->
        columns[ele['id']] = 'checkbox'
        names.push( ele['name'] )

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

  # Engineering Project, generate salary table link
  $('.generate_salary_table_link').on 'click', (e) ->
    e.stopPropagation()
    e.preventDefault()

    project_ele = $(this).closest('tr')
    project_id = project_ele.attr('id').split('_')[-1..][0]

    $.getJSON "/engineering_staffs/query_free?project_id=#{project_id}", (data) =>
      amount = project_ele.find('.col-project_amount').text()
      upper_salary = 3500
      project  =
        id: project_id
        name: project_ele.find('.col-name').text()
        start_date: project_ele.find('.col-project_start_date').text()
        end_date: project_ele.find('.col-project_end_date').text()
        range: project_ele.find('.col-project_range').text()
        amount: amount
        upper_salary: upper_salary
        need_staff_count: parseInt(amount/upper_salary)+1
        free_staff_count: data['stat'].length # 30

      ActiveAdmin.modal_dialog_generate_salary_table project, (inputs)=>
        if project['free_staff_count'] >= project['need_staff_count']
          salary_type = $("#salary_type_list_#{project['id']}").find('input:checked').val()
          $.ajax
            url: '/engineering_projects/' + project['id'] + '/generate_salary_table'
            type: 'post'
            data:
              salary_type: salary_type
            dataType: 'json'
            success: (data, textStatus, jqXHR) ->
              alert( data['message'] )

  # Manipulate Insurance Fund
  $('a[data-action=manipulate_insurance_fund]').on 'click', ->
    $('.ui-dialog-title').text('请选择');

    list = $('#dialog_confirm ul')
    list.empty();

    for key,val of $(this).data('inputs')
      id = key.split('_')[0..-2].join('_')
      name = key.split('_')[-1..-1].join()

      if id == 'salary_deserve_to_insurance_fund'
        list.append("<li><hr></li>")
        list.append("<li class='reverse'><input type='checkbox' class='batch_update_protect_fild_flag' value='Y' id='batch_update_dialog_"+id+"'><label for='batch_update_dialog_"+id+"'> "+name+"</label></br><input name='"+id+"' class='' type='text' style='display:none;'></li>")
      else
        list.append("<li class='normal'><input type='checkbox' class='batch_update_protect_fild_flag' value='Y' id='batch_update_dialog_"+id+"'><label for='batch_update_dialog_"+id+"'> "+name+"</label></br><input name='"+id+"' class='' type='text' style='display:none;'></li>")

    list.find('.normal .batch_update_protect_fild_flag').on 'click', ->
      if $(@).is(':checked')
        $(@).siblings('input').val('selected')
        $(@).closest('li').siblings('.reverse').each ->
          $(@).find('.batch_update_protect_fild_flag').prop('checked', false)
          $(@).find('input[type=text]').val('')
      else
        $(@).siblings('input').val('')

    list.find('.reverse .batch_update_protect_fild_flag').on 'click', ->
      if $(@).is(':checked')
        $(@).siblings('input').val('selected')
        $(@).closest('li').siblings('.normal').each ->
          $(@).find('.batch_update_protect_fild_flag').prop('checked', false)
          $(@).find('input[type=text]').val('')
      else
        $(@).siblings('input').val('')

  # URLs
  url = window.location.href.toString().split(window.location.host)[1]
  current_path = url.split('?')[0].replace('#', '')
  query_string = url.split('?')[1]

  # Add View
  html =  """
          <div class='views_selector dropdown_menu'>
            <a class='dropdown_menu_button' href='#'>视图</a>
            <div class='dropdown_menu_list_wrapper' style='display: none;'><div class='dropdown_menu_nipple'></div>
              <ul class='dropdown_menu_list'>
                <li><a href='#{current_path}'>普通工资表</a></li>
                <li><a href='#{current_path}?view=proof'>凭证工资表（帐用）</a></li>
                <li><a href='#{current_path}?view=card'>打卡表</a></li>
                <li class='custom'><a href='#{current_path}?view=custom'>自定义</a></li>
              </ul>
            </div>
          </div>
          """

  $('body.salary_items .table_tools').append(html)

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

  # Normal Staff sidebar
  current_contract = $('body.normal_staffs .current_contract')
  current_contract.css("padding-right", "10px")
  current_contract.closest('li').append("<span class='status_tag active ok'>当前合同</span>")

  # Import Introduction
  $('.normal_corporation .import_guide ol').append('<li>3. 字段"管理费收取方式"的有效值为：每人固定比例（应发工资），每人固定比例（应发工资+单位缴费），每人固定金额</li>')

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
  idx = 0
  for name, type of inputs
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
      <li>
        <label style='float:left'>#{display_names[idx]}</label>
        <select name="#{name}" class="current_staff_select" type="" checked='checked' multiple style='height:200px;width:100px;'>
          <option selected disabled>请选择</option>
    """

    for v in opts
      html += "<option value='#{v[1]}'>#{v[0]}</option>"

    html += "</select></li>"

    [wrapper, elem, opts, type, klass] = [] # unset any temporary variables

    idx += 1

  # Other customers
  html += """
    <li>
      <label style='float:left'>其他客户可用员工 <a href='#' class='load_select'>(加载)</a></label>
      <select name="" class="other_customer_select" type="" checked='checked' style='display:none;float:left;margin-right:10px;'>
        <option class='default_option' disabled>请选择</option>
      </select>
      <select name '' class='other_staff_select' checked='checked' multiple style='display:none;height:200px;width:100px'>
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
            <option value="#{ele['id']}">#{ele['name']}</option>
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
        <li>
          <label>项目名称</label>
          <span>#{data['name']}</span>
        </li>
        <li>
          <label>起止时间</label>
          <span>#{data['start_date']} ~ #{data['end_date']}</span>
        </li>
        <li>
          <label>工作量</label>
          <span>#{data['range']}</span>
        </li>
        <li>
          <label>劳务费</label>
          <span>#{data['amount']}</span>
        </li>
        <li>
          <label>员工工资上限</label>
          <span>#{data['upper_salary']}</span>
        </li>
        <li>
          <label>需提供员工数</label>
          <span>#{data['need_staff_count']}</span>
        </li>
        <li>
          <label>可用员工数</label>
          <span>#{data['free_staff_count']}</span>
        </li>
  """

  if data['free_staff_count'] >= data['need_staff_count']
    html += """
      <li id="salary_type_list_#{data['id']}">
        <label>工资表类型</label>
        <input type="radio" name="salary_type" value="EngineeringNormalSalaryTable" checked> 基础</input>
        <input type="radio" name="salary_type" value="EngineeringNormalWithTaxSalaryTable"> 基础（带个税）</input>
        <input type="radio" name="salary_type" value="EngineeringBigTableSalaryTable"> 大表</input>
        <input type="radio" name="salary_type" value="EngineeringDongFangSalaryTable"> 东方</input>
      </li>
    """
  else
    html += """
      <li>
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
    dialogClass: 'active_admin_dialog'
    buttons:
      OK: ->
        callback $(@).serializeObject()
        $(@).dialog('close')
      Cancel: ->
        $(@).find('option:checked').prop('selected', false)
        $(@).dialog('close').remove()
