library = Library.create

[
  { name: 'human' },
  { name: 'dwarf' },
  { name: 'elf' },
  { name: 'halfling', size: 'small' }
].each { |attributes| library.races.create(attributes) }

[
  {
    name: 'barbarian',
    bab: 'full',
    fort: 'good',
    reflex: 'bad',
    will: 'bad'
  },
  {
    name: 'paladin',
    bab: 'full',
    fort: 'good',
    reflex: 'bad',
    will: 'bad',
    features: [{ level: 2, name: 'divine grace', effects: [{ fort: 'cha', reflex: 'cha', will: 'cha' }] }]
  },
  {
    name: 'rogue',
    bab: 'three_quarters',
    fort: 'bad',
    reflex: 'good',
    will: 'bad'
  }
].each { |attributes| library.cclasses.create(attributes) }

[
  {
    name: 'toughness',
    effects: [{ hp: 3 }]
  },
  {
    name: 'iron will',
    effects: [{ will: 2 }]
  }
].each { |attributes| library.feats.create(attributes) }

character = Character.new(race: library.races.first, name: 'Bob')
character.levels.gain(library.cclasses.first, 12, feats: [library.feats.first, library.feats.last])
character.save!
