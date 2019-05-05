require_relative "../config/environment.rb"
require "pry"

class Student
  attr_reader :grade
  attr_writer
  attr_accessor :id, :name

  def initialize(name, grade, id = nil)
    @name = name
    @grade = grade
    @id = id
  end

  # class DB methods

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS students (
      id INTEGER PRIMARY KEY,
      name TEXT,
      grade TEXT
    )
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS students"
    DB[:conn].execute(sql)
  end


  def self.create(name, grade)
    Student.new(name, grade).save           #lops it all together, initialize a new student and save that same student
  end


  def self.new_from_db(values)
    Student.new(values[1], values[2], values[0])
    #the id was optional and the variables were posistional
  end

  def self.find_by_name(value)

    sql = <<-SQL
      SELECT *
      FROM students
      WHERE name = ?
      LIMIT 1
    SQL

    DB[:conn].execute(sql, value).map do |row|
      self.new_from_db(row)
    end.first


  end






  def update
    sql = <<-SQL
      UPDATE students
      SET name = ?
      WHERE id = ?
    SQL
                        #set the name as the new name but only if the id's match
    DB[:conn].execute(sql, self.name, self.id)

  end

  def save
    if self.id
      self.update

    else
      sql = <<-SQL
        INSERT INTO students (name, grade)
        VALUES (?, ?)
      SQL

      DB[:conn].execute(sql, self.name, self.grade)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM students")[0][0]
    end
  end


end
