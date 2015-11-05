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

