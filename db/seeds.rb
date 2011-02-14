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
  ),
  {
    name: 'paladin',
    bab: 'full',
    fort: 'good',
    reflex: 'bad',
    will: 'bad'
  },
  {
    name: 'rogue',
    bab: 'three_quarters',
    fort: 'bad',
    reflex: 'good',
    will: 'bad'
  }
].each { |attributes| library.cclasses.create(attributes) }
