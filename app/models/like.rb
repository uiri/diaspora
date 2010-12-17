#   Copyright (c) 2010, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class HandleValidator < ActiveModel::Validator
  def validate(document)
    unless document.diaspora_handle == document.person.diaspora_handle
      document.errors[:base] << "Diaspora handle and person handle must match"
    end
  end
end

class Like < Comment

  xml_reader :dislike

  key :dislike, Boolean, :default => false

  def self.hash_from_post_ids post_ids
    hash = {}
    likes = self.on_posts(post_ids)
    post_ids.each do |id|
      hash[id] = []
    end
    likes.each do |like|
      hash[like.post_id] << like
    end
    hash.each_value {|likes| likes.sort!{|l1, l2| l1.created_at <=> l2.created_at }}
    hash
  end
  scope :on_posts, lambda { |post_ids|
    where(:post_id.in => post_ids)
  }
end
