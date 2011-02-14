class Library
  include Mongoid::Document

  embeds_many :races
  embeds_many :cclasses
end
