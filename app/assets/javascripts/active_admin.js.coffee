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

      list.append("<li><input type='checkbox' class='batch_update_protect_fild_flag' value='Y' id='batch_update_dialog_"+id+"'><label for='batch_update_dialog_"+id+"'> "+name+"</label></br><input name='"+id+"' class='' type='text' disabled='disabled'></li>")

    $('input.batch_update_protect_fild_flag').on 'click', ->
      input = $(this).siblings('input')
      if input.attr('disabled') == 'disabled'
        input.removeAttr('disabled')
      else
        input.attr('disabled', 'disabled')

