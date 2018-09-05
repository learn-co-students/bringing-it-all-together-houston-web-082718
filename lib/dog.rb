class Dog

  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
      @name = name
      @breed = breed
      @id = id
  end

  def self.create_table
    sql = "CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )"
      DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE dogs"
    DB[:conn].execute(sql)
  end

  def save
    sql = "INSERT INTO dogs (name, breed) VALUES (?, ?)"
    DB[:conn].execute(sql, @name, @breed)

    sql = "SELECT last_insert_rowid() FROM dogs"
    @id = DB[:conn].execute(sql)[0][0]
    self
  end

  def self.create(name:, breed:)
    self.new(name: name, breed: breed).save
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM dogs WHERE id = ?"
    data = DB[:conn].execute(sql, id)[0]
    self.new(name: data[1], breed: data[2], id: data[0])
  end

  def self.find_or_create_by(name:, breed:)
    sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
    data = DB[:conn].execute(sql, name, breed)
    if data.length == 0
      self.create(name: name, breed: breed)
    else
      self.new(name: data[0][1], breed: data[0][2], id: data[0][0])
    end
  end

  def self.new_from_db(attributes)
    self.new(name: attributes[1], breed: attributes[2], id: attributes[0])
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM dogs WHERE name = ?"
    self.new_from_db(DB[:conn].execute(sql, name)[0])
  end

  def update
    sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
    DB[:conn].execute(sql, @name, @breed, @id)
  end
end
