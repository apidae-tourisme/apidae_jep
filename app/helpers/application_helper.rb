module ApplicationHelper
  def controller?(*controller)
    controller.include?(params[:controller])
  end

  def action?(*action)
    action.include?(params[:action])
  end
end

module ActionView
  module Helpers
    class FormBuilder
      def date_select(method, options = {}, html_options = {})
        existing_date = @object.send(method)
        formatted_date = existing_date.to_date.strftime("%d/%m/%Y %R") if existing_date.present?
        @template.content_tag(:div, :class => 'input-group date datepicker') do
          text_field(method, {:value => formatted_date, :class => 'form-control', style: 'display: none'}.merge(html_options)) +
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