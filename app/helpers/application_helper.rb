module ApplicationHelper
  def controller?(*controller)
    controller.include?(params[:controller])
  end

  def action?(*action)
    action.include?(params[:action])
  end

  def date_select_tag(method, html_options = {})
    content_tag(:div, :class => 'input-group date datepicker w100') do
      text_field('opening', method, {class: 'hidden'}.merge(html_options))
    end
  end

  def time_select_tag(method, html_options = {})
    content_tag(:div, :class => 'input-group date datetimepicker mauto bg-white p') do
      text_field('opening', method, {class: 'hidden'}.merge(html_options))
    end
  end

  def help_button
    '<button type="button" class="help_button btn btn-xs"><i class="fa fa-question-circle text-info"></i></button>'.html_safe
  end

  def help_content(help_text)
    ('<span class="help-block hidden">' + help_text + '</span>').html_safe
  end

  def item_icon(item_type)
    case item_type
      when ITEM_VISITE
        'fa-institution'
      when ITEM_PARCOURS
        'fa-map-signs'
      when ITEM_ANIMATION
        'fa-microphone'
      when ITEM_EXPOSITION
        'fa-photo'
      else
        'fa-institution'
    end
  end
end

module ActionView
  module Helpers
    class FormBuilder
      def date_select(method, options = {}, html_options = {})
        existing_date = @object.send(method)
        formatted_date = existing_date.to_date.strftime("%d/%m/%Y %R") if existing_date.present?
        @template.content_tag(:div, :class => 'input-group date datepicker') do
          text_field(method, {:value => formatted_date, :class => 'form-control'}.merge(html_options)) +
              @template.content_tag(:span, @template.content_tag(:span, '', :class => 'fa fa-calendar') , :class => 'input-group-addon')
        end
      end

      def datetime_select(method, options = {}, html_options = {})
        existing_time = @object.send(method)
        formatted_time = existing_time.to_time.strftime("%d/%m/%Y %R") if existing_time.present?
        @template.content_tag(:div, :class => 'input-group date datetimepicker') do
          text_field(method, {:value => formatted_time, :class => 'form-control'}.merge(html_options)) +
              @template.content_tag(:span, @template.content_tag(:span, "", :class => 'fa fa-clock-o') , :class => 'input-group-addon')
        end
      end
    end
  end
end