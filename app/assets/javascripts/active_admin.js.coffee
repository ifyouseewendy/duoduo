#= require active_admin/base

$(document).on 'ready', ->
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

  url = window.location.href.toString().split(window.location.host)[1]
  current_path = url.split('?')[0]
  query_string = url.split('?')[1]

  html =  """
          <div class='views_selector dropdown_menu'>
            <a class='dropdown_menu_button' href='#'>视图</a>
            <div class='dropdown_menu_list_wrapper' style='display: none;'><div class='dropdown_menu_nipple'></div>
              <ul class='dropdown_menu_list'>
                <li><a href='#{current_path}'>原始工资表</a></li>
                <li><a href='#{current_path}?view=archive'>存档工资表</a></li>
                <li><a href='#{current_path}?view=proof'>凭证工资表</a></li>
                <li><a href='#{current_path}?view=card'>打卡表</a></li>
                <li><a href='#{current_path}?view=custom'>自定义</a></li>
              </ul>
            </div>
          </div>
          """

  $('body.salary_items .table_tools').append(html)

  $('.views_selector .dropdown_menu_button').on 'click', ->
    list = $(@).next('.dropdown_menu_list_wrapper')
    if list.css('display') == 'none'
      list.css('top', '174px')
      list.find('.dropdown_menu_nipple').css('left', '20px')
      list.show();
    else
      list.hide();

  html =  """
          <span>下载:</span>
          <a href="#{current_path}/export_xlsx?#{query_string}">XLSX</a>
          """
  $('body.salary_items .download_links').empty().append(html)
