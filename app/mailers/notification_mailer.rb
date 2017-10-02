class NotificationMailer < ApplicationMailer
  include Rails.application.routes.url_helpers

  def notify(item)
    @item = item
    moderators = Rails.application.config.moderators[@item.user.territory]
    @comment = @item.history_entry(ProgramItem::STATUS_PENDING) ? @item.history_entry(ProgramItem::STATUS_PENDING)[:description] : ''
    mail(to: moderators, subject: "#{Rails.application.config.notification_title} - #{@item.title}")
  end

  def reject(item)
    @item = item
    @signature = Rails.application.config.signature[@item.user.territory]
    @comment = @item.history_entry(ProgramItem::STATUS_REJECTED) ? @item.history_entry(ProgramItem::STATUS_REJECTED)[:description] : ''
    mail(to: item.user.email, subject: "#{Rails.application.config.rejection_title} - #{@item.title}")
  end

  def publish(item)
    @item = item
    @signature = Rails.application.config.signature[@item.user.territory]
    mail(to: item.user.email, subject: "#{Rails.application.config.publication_title} - #{@item.title}")
  end

  def notify_poll(user)
    @user = user
    mail(from: 'jep.metropole@grandlyon.com', to: user.email, subject: Rails.application.config.notify_poll_title)
  end
end
