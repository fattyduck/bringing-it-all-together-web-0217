require 'pry'

class Dog

  attr_accessor :name, :breed, :id

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    create_table_sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs(
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL

    DB[:conn].execute(create_table_sql)
  end

  def self.drop_table
    drop_table_sql = <<-SQL
      DROP TABLE IF EXISTS dogs
    SQL

    DB[:conn].execute(drop_table_sql)
  end


  def save
    self.class.insert(self.name, self.breed)
    row = self.class.find(self.name, self.breed)
    self.id = row[0]
    self.name = row[1]
    self.breed = row[2]
    self
  end

  def self.find_by_id(id)
    find_by_id_sql =<<-SQL
      SELECT * FROM dogs
      WHERE id = ?
    SQL
    row = DB[:conn].execute(find_by_id_sql, id)
    self.new(id: id, name: row[1], breed: row[2])
  end

  def self.create(name:, breed:)
    insert(name, breed)
    row = find(name, breed)
    self.new(id: row[0],name: name, breed:breed)
  end

  def self.find(name, breed)
    find_sql = <<-SQL
      SELECT * FROM dogs
      WHERE name = ? and breed = ?
    SQL

    DB[:conn].execute(find_sql, name, breed).flatten
  end

  def self.insert(name, breed)

    insert_sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL

    DB[:conn].execute(insert_sql, name, breed)
  end

  def self.find_or_create_by(name:, breed:)
    if find(name, breed)[0]
      return find_by_id(find(name, breed)[0])
    else
      create(name: name, breed: breed)
    end
  end

  def self.find_by_name(name)
      find_by_name_sql =<<-SQL
        SELECT * FROM dogs
        WHERE name = ?
      SQL
      row = DB[:conn].execute(find_by_name_sql, name).flatten
      self.new(id: row[0],name: name, breed: row[2])
      #binding.pry

  end

  def update
    update_sql = <<-SQL
      UPDATE dogs
      SET name = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(update_sql, self.name, self.id)
  end

  def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
  end
end
