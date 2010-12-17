#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Comment do
  let(:user)    {make_user}
  let(:aspect)  {user.aspects.create(:name => "Doofuses")}

  let(:user2)   {make_user}
  let(:aspect2) {user2.aspects.create(:name => "Lame-faces")}

  let!(:connecting) { connect_users(user, aspect, user2, aspect2) }

 describe '.hash_from_post_ids' do
   before do
      @hello = user.post(:status_message, :message => "Hello.", :to => aspect.id)
      @hi = user.post(:status_message, :message => "hi", :to => aspect.id)
      @lonely = user.post(:status_message, :message => "Hello?", :to => aspect.id)

      @l11 = user2.comment "likes this", :on => @hello
      @l21 = user2.comment "likes this", :on => @hi
      @l12 = user.comment "likes this", :on => @hello
      @l22 = user.comment "likes this", :on => @hi

      @l12.created_at = Time.now+10
      @l12.save!
      @l22.created_at = Time.now+10
      @l22.save!
    end
    it 'returns an empty array for posts with no likes' do
      Like.hash_from_post_ids([@lonely.id]).should ==
        {@lonely.id => []}
    end
    it 'returns a hash from posts to comments' do
      Like.hash_from_post_ids([@hello.id, @hi.id]).should ==
        {@hello.id => [@l11, @l12],
         @hi.id => [@l21, @l22]
      }
    end
    it 'gets the people from the db' do
      hash = Like.hash_from_post_ids([@hello.id, @hi.id])
      Person.from_post_comment_hash(hash).should == {
        user.person.id => user.person,
        user2.person.id => user2.person,
      }
    end
   end
end
