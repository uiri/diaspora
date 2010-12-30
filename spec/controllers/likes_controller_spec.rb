#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe LikesController do
  render_views

  let!(:user) { make_user }
  let!(:aspect) { user.aspects.create(:name => "AWESOME!!") }

  let!(:user2) { make_user }
  let!(:aspect2) { user2.aspects.create(:name => "WIN!!") }

  before do
    sign_in :user, user
  end

  describe '#create' do
    let(:like_hash) {
      {:text => "likes this",
       :post_id =>"#{@post.id}"}
    }
    context "on my own post" do
      before do
        @post = user.post :status_message, :message => 'GIANTS', :to => aspect.id
      end
      it 'responds to format js' do
        post :create, like_hash.merge(:format => 'js'), :dislike => false
#        response.code.should == '201'
        response.body.should match like_hash[:text]
      end
    end
    context "on a post from a contact" do
      before do
        connect_users(user, aspect, user2, aspect2)
        @post = user2.post :status_message, :message => 'GIANTS', :to => aspect2.id
      end
      it 'likes' do
        post :create, like_hash, :dislike => false
        response.code.should == '201'
      end
      it "doesn't like twice" do
        post :create, like_hash, :dislike => false
        response.code.should == '409'
      end
      it "doesn't like and dislike" do
        post :create, like_hash, :dislike => true
        response.code.should == '409'
      end
      it "doesn't overwrite person_id" do
        new_user = make_user
        like_hash[:person_id] = new_user.person.id.to_s
        post :create, like_hash, :dislike => false
        Like.find_by_post(like_hash[:post_id]).person_id.should == user.person.id
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
        @post = user2.post :status_message, :message => 'GIANTS', :to => aspect2.id
      end
      it 'posts no like' do
        user.should_receive(:like).exactly(0).times
        post :create, like_hash, :dislike => false
        response.code.should == '406'
      end
    end
  end
end
