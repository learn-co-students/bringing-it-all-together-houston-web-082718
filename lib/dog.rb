class Dog

    attr_accessor :name, :breed, :id

    def initialize (props={})
        @name = props[:name]
        @breed = props[:breed]
        @id = nil
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE IF NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name STRING,
                breed STRING
            )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
            DROP TABLE IF EXISTS dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
            INSERT INTO dogs (name, breed) VALUES (?,?)
        SQL

        new_dog = DB[:conn].execute(sql, self.name, self.breed)
        
        get_id = <<-SQL
            SELECT id FROM dogs WHERE name = ? AND breed = ?
        SQL
        
        
        
        self.id = DB[:conn].execute(get_id, self.name, self.breed)[0][0]

        self
    end

    def self.create(dog_hash)
        new_dog = Dog.new(dog_hash)
        new_dog.save
        new_dog
    end

    def self.find_by_id(n)
        sql = <<-SQL
            SELECT * FROM dogs WHERE id = ?
        SQL

        found = DB[:conn].execute(sql, n)[0]
        new_dog = Dog.create(name: found[1], breed: found[2])
        
    end

    def self.find_or_create_by (dog_hash)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ? AND breed = ?
        SQL

        found_dogs = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed])
        if found_dogs.length > 0 
            new_dog = Dog.new(name: found_dogs.first[1], breed: found_dogs.first[2])
            new_dog.id = found_dogs.first.first
        else
            new_dog = Dog.create(name: dog_hash[:name], breed: dog_hash[:breed])
        end
        new_dog
    end

    def self.new_from_db (arr)
        doge = Dog.new(name: arr[1], breed: arr[2])
        doge.id = arr[0]
        doge
    end

    def self.find_by_name (name)
        sql = <<-SQL
            SELECT * FROM dogs WHERE name = ?
        SQL

        found_name = DB[:conn].execute(sql, name)
        self.new_from_db(found_name.first)
    end

    def update
        sql = <<-SQL
            UPDATE dogs SET name = ?, breed = ? WHERE id = ?
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end