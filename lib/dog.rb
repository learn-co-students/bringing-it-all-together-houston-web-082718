

# The #initialize method 

# ::create_table Your task here is to define a class method on Dog that will execute the correct SQL to create a dogs table.

class Dog

    # has a name and a breed 
    attr_accessor :id, :name, :breed

    # accepts a hash or keyword argument value with key-value pairs as an argument. 
    # key-value pairs need to contain id, name, and breed.
    # has an id that defaults to `nil` on initialization
    # accepts key value pairs as arguments to initialize
    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    # creates the dogs table in the database 
    def self.create_table
        sql = "CREATE TABLE IF NOT EXISTS dogs (id INTEGER PRIMARY KEY, name STRING, breed STRING)"

        DB[:conn].execute(sql)
    end

    # drops the dogs table from the database
    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    # returns an instance of the dog class
    def save
        if self.id
            self

        # saves an instance of the dog class to the database and 
        # then sets the given dogs `id` attribute
        else
            sql = "INSERT INTO dogs (name, breed) VALUES (?,?)"
            DB[:conn].execute(sql, self.name, self.breed)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            self
        end
    end

    # takes in a hash of attributes and uses metaprogramming to create a new dog object. 
    # Then it uses the #save method to save that dog to the database
    def self.create(name:, breed:)
        new_dog = Dog.new(name: name, breed: breed)
        new_dog.save
    end

    # returns a new dog object by id
    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        row = DB[:conn].execute(sql, id)[0]
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    
    def self.find_or_create_by(name:, breed:)
        sql = "SELECT * FROM dogs WHERE name = ? AND breed = ?"
        row = DB[:conn].execute(sql, name, breed)

        # when creating a new dog with the same name as persisted dogs, 
        # it returns the correct dog
        if !row.empty?
            Dog.new(id: row[0][0], name: row[0][1], breed: row[0][2])

        # creates an instance of a dog if it does not already exist
        # when two dogs have the same name and different breed, it returns the correct dog
        else
            self.create(name: row[1], breed: row[2])
        end
    end

    # creates an instance with corresponding attribute values
    def self.new_from_db(row)
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    # returns an instance of dog that matches the name from the DB
    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        row = DB[:conn].execute(sql, name)[0]
        Dog.new(id: row[0], name: row[1], breed: row[2])
    end

    # updates the record associated with a given instance
    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end