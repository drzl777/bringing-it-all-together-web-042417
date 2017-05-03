require 'pry'

class Dog
  attr_accessor :name, :breed
  attr_reader :id

  def initialize(attributes)
    @name, @breed = attributes[:name], attributes[:breed]
    attributes.include?(:id) ? @id = attributes[:id] : @id = nil
  end

  def self.create_table

    sql = '''
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    )'''

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"

    DB[:conn].execute(sql)
  end

  def save
    insert_sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    new_dog_arr = DB[:conn].execute(insert_sql, self.name, self.breed)
    find_id_sql = "SELECT last_insert_rowid() FROM dogs"
    @id = DB[:conn].execute(find_id_sql).flatten.first
    self
  end

  def self.create(attributes)
    new_dog = self.new(attributes)
    new_dog.save
    new_dog
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    dog_arr = DB[:conn].execute(sql, id).flatten
    if dog_arr
      dog_attr_hash = {id: dog_arr[0], name: dog_arr[1], breed: dog_arr[2]}
      self.new(dog_attr_hash)
    else
      nil
    end
  end

  def self.find_or_create_by(attributes)
    name, breed = attributes[:name], attributes[:breed]
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    found_dog = DB[:conn].execute(sql, name, breed).flatten
    #binding.pry
    if found_dog.size == 0
      new_dog = self.create(attributes)
    else
      attributes[:id] = found_dog.first
      self.new(attributes)
    end
  end

  def self.new_from_db(row)
    dog_attr_hash = {id: row[0], name: row[1], breed: row[2]}
    self.new(dog_attr_hash)
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"

    dog_row = DB[:conn].execute(sql, name).flatten
    dog_attr_hash = {id: dog_row[0], name: dog_row[1], breed: dog_row[2]}
    self.new(dog_attr_hash)
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
