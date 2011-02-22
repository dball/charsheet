class Library
  include Mongoid::Document

  embeds_many :races
  references_many :cclasses
  references_many :feats
end
