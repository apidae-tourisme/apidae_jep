module LoggableConcern
  extend ActiveSupport::Concern

  EVENT_STATUS_CHANGE = 'status_change'
  EVENT_NEW_COMMENT = 'new_comment'

  included do
    attr_accessor :comment, :author, :timestamp

    store :history_data, accessors: [:history], coder: JSON
    before_save :log_change

    def log_change
      self.history ||= []
      if self.valid?
        ts = @timestamp || Time.current.to_i.to_s
        if status_changed?
          self.history << {timestamp: ts, event_type: EVENT_STATUS_CHANGE, event_status: self.status,
                           description: @comment, author: @author}
        elsif !@comment.blank?
          self.history << {timestamp: ts, event_type: EVENT_NEW_COMMENT, event_status: self.status,
                           description: @comment, author: @author}
        end
      end
    end

    def history_entries
      history.nil? ? [] : history.uniq {|h| [h[:event_type], h[:event_status], h[:description]].join('')}.sort_by {|h| h[:timestamp].to_i}.reverse
    end

    def history_entry(status)
      history.select {|h| h[:event_status] == status}.sort_by {|h| h[:timestamp].to_i}.last
    end

    def last_change
      if history.blank?
        updated_at
      else
        last_change = history.select {|h| h[:event_type] == EVENT_STATUS_CHANGE}.sort_by {|h| h[:timestamp].to_i}.reverse.first
        last_change ? Time.at(last_change[:timestamp].to_i) : updated_at
      end
    end
  end
end
