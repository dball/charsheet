class Library
  include Mongoid::Document

  embeds_many :races
  references_many :cclasses
end
