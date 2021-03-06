# frozen_string_literal: true

class SnsReceiverJob < ApplicationJob
  queue_as :default

  # Receive hook
  def perform(track_type, m, _referrer)
    data = m[track_type]

    message_id = parsed_message_id(m)
    metric = Metric.find_by(message_id: message_id)
    return if metric.blank?

    campaign = metric.trackable
    app_user = metric.app_user

    # TODO: unsubscribe on spam (complaints that are non no-spam!)
    # app_user.unsubscribe! if track_type == "spam"
    app_user.send("track_#{track_type}".to_sym,
                  host: data['ipAddress'],
                  trackable: campaign,
                  message_id: message_id,
                  data: data)
  end

  def parsed_message_id(m)
    m['mail']['headers'].find { |o| o['name'] == 'Message-ID' }['value'].split('@').first.gsub('<', '')
  end
end
