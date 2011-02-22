#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class LikesController < CommentsController
  include ApplicationHelper
  before_filter :authenticate_user!

  respond_to :html
  respond_to :json, :only => :show

  def create
    target = current_user.find_visible_post_by_id params[:post_id]
    if !target
      render :nothing => true, :status => 406
    elsif target.likes.where(:person_id => current_user.id).any?
      render :nothing => true, :status => 409
    else
      text = 'likes this'

      if target
        @like = current_user.build_like(text, :on => target)
      
        if @like.save
          Rails.logger.info("event=create type=like user=#{current_user.diaspora_handle} status=success like=#{@like.id}")

          current_user.dispatch_like(@like)

          respond_to do |format|
            format.js{
              json = { :post_id => @like.post_id,
                                         :like_id => @like.id,
                                         :html => render_to_string(
                                           :partial => 'likes/like',
                                           :locals => { :like => @like,
                                             :person => current_user.person,
                                           }
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
  end
end
