class Library
  include Mongoid::Document

  embeds_many :races
end
