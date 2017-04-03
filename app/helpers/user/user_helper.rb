module User::UserHelper
  def help_button
    '<button type="button" class="help_button btn btn-xs"><i class="fa fa-question-circle text-info"></i></button>'.html_safe
  end

  def help_content(help_text)
    ('<span class="help-block hidden">' + help_text + '</span>').html_safe
  end
end