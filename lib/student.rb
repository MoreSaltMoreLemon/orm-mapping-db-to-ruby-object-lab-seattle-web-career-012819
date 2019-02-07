require 'pry'
class Student
  attr_accessor :id, :name, :grade

  # create a new Student object given a row from the database
  def self.new_from_db(row)
    # binding.pry
    student = Student.new
    student.id = row[0]
    student.name = row[1]
    student.grade = row[2]
    student
  end

  # retrieve all the rows from the "Students" database
  # remember each row should be a new instance of the Student class
  def self.all
    sql = <<-SQL
      SELECT * FROM students;
    SQL

    rows = DB[:conn].execute(sql)

    rows.map do |row|
      self.new_from_db(row)
    end
  end

  # find the student in the database given a name
  # return a new instance of the Student class
  def self.find_by_name(name)
    sql = <<-SQL
      SELECT * FROM students WHERE students.name = ? LIMIT 1;
    SQL

    student_row = DB[:conn].execute(sql, name)[0]
    self.new_from_db(student_row)
  end

  def self.all_students_in_grade_9
    self.all.select do |student|
      student.grade == "9"
    end
  end

  def self.students_below_12th_grade
    self.all.select do |student|
      student.grade.to_i < 12
    end
  end

  def self.first_X_students_in_grade_10(x)
    puts x
    students = self.all.select do |student|
      student.grade == "10"
    end
    students[0..(x - 1)]
  end

  def self.first_student_in_grade_10
    self.first_X_students_in_grade_10(1).first
  end

  def self.all_students_in_grade_X(grade)
    self.all.select do |student|
      student.grade = grade
    end
  end
  
  def save
    sql = <<-SQL
      INSERT INTO students (name, grade) 
      VALUES (?, ?)
    SQL

    DB[:conn].execute(sql, self.name, self.grade)
  end
  
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
end
