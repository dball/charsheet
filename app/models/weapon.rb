class Weapon < Equipment

  field :light, :type => Boolean, :default => false

  field :critical_threshold, :type => Integer, :default => 20
  validates_numericality_of :critical_threshold,
    allow_nil: false, only_integer: true,
    less_than_or_equal_to: 20, greater_than: 0

  field :critical_multiplier, :type => Integer, :default => 2
  validates_numericality_of :critical_multiplier,
    allow_nil: false, only_integer: true,
    greater_than: 1

  field :hands_wielding, :type => Integer, :default => 1
  validates_numericality_of :hands_wielding,
    allow_nil: false, only_integer: true,
    greater_than_or_equal_to: 1, less_than_or_equal_to: 2

  def all_effects
    super + (masterwork? ? [Effect.new(bonus: 'enhancement', attack: 1)] : [])
  end

  def self.parse(value)
    params = {}
    if value.sub!(/^masterwork /, '')
      params[:masterwork] = true
    elsif value.sub!(/^\+(\d+) /, '')
      params[:masterwork] = true
      bonus = Integer($1)
      params[:effects] = [{ type: 'enhancement', attack: bonus, damage: bonus }]
    end
    params[:name] = value
    new(params)
  end

end
