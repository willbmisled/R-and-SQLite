# Load required packages and set the working directory
library(sqldf)      # Loads RSQLite
library(XLConnect)  # To read Excel sheets and workbooks

setwd('./Data')  # But modify path if alternative path needed.

# Remove files if they already exist:
  if (file.exists("Test.sqlite") == TRUE) file.remove("Test.sqlite")

#create and populate a database
  # Creates the database if none exists Or connects to the database if one already exists.
    db <- dbConnect(SQLite(), dbname="Test.sqlite")
  
  #create a table enter data directly from R
    #create table named "School" in "Test.sqlite"
      dbSendQuery(conn = db, 
       "CREATE TABLE School 
       (SchID INTEGER, 
        Location TEXT,
        Authority TEXT,
        SchSize TEXT)")

    #enter data by hand.
      dbSendQuery(conn = db, 
        "INSERT INTO School
         VALUES (1, 'urban', 'state', 'medium')")
      dbSendQuery(conn = db, 
        "INSERT INTO School
         VALUES (2, 'urban', 'independent', 'large')")
      dbSendQuery(conn = db, 
        "INSERT INTO School
         VALUES (3, 'rural', 'state', 'small')")

    #check the work
      dbListTables(db)                         # List the tables in the database
      dbListFields(db, "School")               # List the columns in a table
      dbReadTable(db, "School")                # Display the data in a table method1
      dbGetQuery(db, "SELECT * from School")   # Display the data in a table method2

    #To remove this table
      #dbRemoveTable(db, "School") 

  #create a table from an existing CSV files (class.csv)
    dbWriteTable(conn = db, name = "Class", value = "class.csv", eol = "\r\n", row.names = FALSE, header = TRUE)

    #check the work
      dbListTables(db)                         # List the tables in the database
      dbListFields(db, "Class")                # List the columns in a table
      dbReadTable(db, "Class")                 # Display the data in a table


  # Alternatively, one create a table from a dataframe
    #read a csv files into R as dataframe
      Student <- read.csv("student.csv")  # Read csv files into R
    
    # then import the dataframes into the database. 
      dbWriteTable(conn = db, name = "Student", value = Student, row.names = FALSE)

    #check the work
      dbListTables(db)                          # List the tables in the database
      dbListFields(db, "Student")               # List the columns in a table
      dbReadTable(db, "Student")                # Dispaly the data in a table


