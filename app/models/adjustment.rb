class Adjustment
  include Mongoid::Document

  embedded_in :character, :inverse_of => :adjustment
  embeds_many :effects

end
