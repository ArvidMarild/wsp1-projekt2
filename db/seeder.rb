require 'sqlite3'

class Seeder

  def self.seed!
    drop_tables
    create_tables
    populate_tables
  end

  def self.drop_tables
    db.execute('DROP TABLE IF EXISTS todo')
  end

  def self.create_tables
    db.execute('CREATE TABLE todo (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                beskrivning TEXT,
                subject TEXT,
                ongoing BOOLEAN NOT NULL,
                importance INTEGER NOT NULL)')
  end

  def self.populate_tables
    db.execute('INSERT INTO todo (title, beskrivning, subject, ongoing, importance) VALUES ("lär dig pythagoras sats",   "Jag vet, det är svårt att förstå", "Matematik", 1, 5)')
  end

  private
  def self.db
    return @db if @db
    @db = SQLite3::Database.new('db/todo.sqlite')
    @db.results_as_hash = true
    @db
  end
end

Seeder.seed!