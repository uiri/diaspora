#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class NotificationsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html


  def update
    note = Notification.where(:recipient_id => current_user.id, :id => params[:id]).first
    if note
      note.update_attributes(:unread => false)
      render :nothing => true
    else
      render :nothing => true, :code => 404
    end
  end

  def index
    @notifications = Notification.for(current_user)
    @group_days = @notifications.group_by{|note| note.created_at.strftime("%B %d") }
    respond_with @notifications
  end
end