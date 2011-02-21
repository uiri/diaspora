#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Like < Comment

  def receive(user, person)
    local_like = Like.where(:guid => self.guid).first
    like = local_like || self

    unless comment.post.person == user.person || comment.verify_post_creator_signature
      Rails.logger.info("event=receive status=abort reason='like signature not valid' recipient=#{user.diaspora_handle} sender=#{self.post.person.diaspora_handle} payload_type=#{self.class} post_id=#{self.post_id}")
      return
    end

    #sign like as post creator if you've been hit UPSTREAM
    if user.owns? like.post
      like.post_creator_signature = like.sign_with_key(user.encryption_key)
      like.save
    end

    #dispatch like DOWNSTREAM, received it via UPSTREAM
    unless user.owns?(like)
      like.save
      user.dispatch_like(like)
    end

    like.socket_to_user(user, :aspect_ids => like.post.aspect_ids)
    like
  end
  
end
