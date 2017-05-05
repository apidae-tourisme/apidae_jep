class NotificationMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  def notify(item)
    @item = item
    moderators = Moderator.where(member_ref: @item.user.territory).collect {|m| m.email}.uniq
    mail(to: moderators, subject: "#{Rails.application.config.notification_title} - #{@item.title}")
  end

  def reject(item)
    @item = item
    @comment = item.comment
    @title = item.title
    mail(to: item.user.email, subject: "#{Rails.application.config.rejection_title} - #{@title}")
  end

  def publish(item)
    @comment = item.comment
    @title = item.title
    mail(to: item.user.email, subject: "#{Rails.application.config.publication_title} - #{@title}")
  end
end
