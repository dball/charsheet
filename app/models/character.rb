class Character
  include MongoMapper::Document         

  key :name, :required => true
  validates_uniqueness_of :name

  Ability::ABILITIES.each do |ability|
    key ability
    validates_numericality_of ability, :allow_nil => true, :only_integer => true
    define_method("#{ability}_modifier".to_sym) do
      (send(ability) - 10) / 2
    end
  end

  has_many :equipment

# Validations :::::::::::::::::::::::::::::::::::::::::::::::::::::
# validates_presence_of :attribute

# Assocations :::::::::::::::::::::::::::::::::::::::::::::::::::::
# belongs_to :model
# many :model
# one :model

# Callbacks ::::::::::::::::::::::::::::::::::::::::::::::::::::::: 
# before_create :your_model_method
# after_create :your_model_method
# before_update :your_model_method 

# Attribute options extras ::::::::::::::::::::::::::::::::::::::::
# attr_accessible :first_name, :last_name, :email

# Validations
# key :name, :required =>  true      

# Defaults
# key :done, :default => false

# Typecast
# key :user_ids, Array, :typecast => 'ObjectId'
  
   
end
