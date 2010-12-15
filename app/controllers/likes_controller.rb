#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class LikesController < CommentsController

  def create(type)
    target = current_user.find_visible_post_by_id params[:post_id]
    if type == 'dislike'
      text = 'dislikes this'
    else
      text = 'likes this'
    end

    @like = current_user.build_comment(text, :on => target)

    if @like.save(:safe => true)
      raise 'MongoMapper failed to catch a failed save' unless @like.id
      Rails.logger.info("event=like_create user=#{current_user.diaspora_handle} status=success like=#{@like.id}")
      current_user.dispatch_comment(@like)

      respond_to do |format|
        format.js{
          json = { :post_id => @like.post_id,
                                     :like_id => @like.id,
                                     :html => render_to_string(
                                       :partial => 'comments/comment',
                                       :locals => { :hash => {
                                         :like => @like,
                                         :person => current_user,
                                        }}
                                      )
                                    }
          render(:json => json, :status => 201)
        }
        format.html{ render :nothing => true, :status => 201 }
      end
    else
      render :nothing => true, :status => 406
    end
  end

end
