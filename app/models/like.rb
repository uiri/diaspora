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

end
