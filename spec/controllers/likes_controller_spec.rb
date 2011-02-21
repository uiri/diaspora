#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe LikesController do
  render_views

  before do
    @user1 = alice
    @user2 = bob

    @aspect1 = @user1.aspects.first
    @aspect2 = @user2.aspects.first

    sign_in :user, @user1
  end

  describe '#create' do
    let(:like_hash) {
      {:text => "likes this",
       :post_id =>"#{@post.id}"}
    }
    context "on my own post" do
      before do
        @post = @user1.post :status_message, :message => 'GIANTS', :to => @aspect1.id
      end
      it 'responds to format js' do
        post :create, like_hash.merge(:format => 'js')
        response.code.should == '201'
        response.body.should match like_hash[:text]
      end
    end
    context "on a post from a contact" do
      before do
        @post = @user2.post :status_message, :message => 'GIANTS', :to => @aspect2.id
      end
      it 'likes' do
        post :create, like_hash
        response.code.should == '201'
      end
      it "doesn't like twice" do
        post :create, like_hash
        response.code.should == '409'
      end
#      it "doesn't like and dislike" do
#        post :create, like_hash
#        response.code.should == '409'
#      end
      it "doesn't overwrite person_id" do
        new_user = Factory.create(:user)
        like_hash[:person_id] = new_user.person.id.to_s
        post :create, like_hash
        Like.find_by_text(like_hash[:text]).person_id.should == @user1.person.id
      end
#      it "doesn't overwrite id" do
#        old_like = user.like("hello", :on => @post)
#        comment_hash[:id] = old_comment.id
#        post :create, comment_hash
#        old_comment.reload.text.should == 'hello'
#      end
    end
    context 'on a post from a stranger' do
      before do
        @post = eve.post :status_message, :message => 'GIANTS', :to => eve.aspects.first.id
      end
      it 'posts no like' do
        @user1.should_not_receive(:like)
        post :create, like_hash
        response.code.should == '406'
      end
    end
  end
end
