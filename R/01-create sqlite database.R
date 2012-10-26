###--- INTRODUCTION ---###
# Using RSQLite and sqldf packages 
# to create and manage a SQLite database.



###--- SEGMENT 1 ---###
# Load required packages and set the working directory
library(sqldf)      # Loads RSQLite
library(XLConnect)  # To read Excel sheets and workbooks

setwd('~/SST/Database')  # But modify path if alternative path needed.



###--- SEGMENT 2 ---###
# Remove files if they already exist:

     ####   WARNING   ###
     # If Test.sqlite, Test1.sqlite, or Test2.sqlite already exist, 
     # the following lines will delete them.

if (file.exists("Test.sqlite") == TRUE) file.remove("Test.sqlite")
if (file.exists("Test1.sqlite") == TRUE) file.remove("Test1.sqlite")
if (file.exists("Test2.sqlite") == TRUE) file.remove("Test2.sqlite")



###--- SEGMENT 3 ---###
# Using RSQLite

# Creates the database if none exists;
# Or connects to the database if one already exists.

db <- dbConnect(SQLite(), dbname="Test.sqlite")



###--- SEGMENT 4 ---###
# Create a table containing school data
dbSendQuery(conn = db, 
       "CREATE TABLE School 
       (SchID INTEGER, 
        Location TEXT,
        Authority TEXT,
        SchSize TEXT)")

# and enter data by hand.
dbSendQuery(conn = db, 
        "INSERT INTO School
         VALUES (1, 'urban', 'state', 'medium')")
dbSendQuery(conn = db, 
        "INSERT INTO School
         VALUES (2, 'urban', 'independent', 'large')")
dbSendQuery(conn = db, 
        "INSERT INTO School
         VALUES (3, 'rural', 'state', 'small')")

dbListTables(db)      # The tables in the database
# But it is a tedious way to enter data.

dbRemoveTable(db, "School")     # Remove the School table.


###--- SEGMENT 5 ---###
# The data are contained in csv files: student.csv, class.csv, and school.csv.
# Import the csv files into the database.
dbWriteTable(conn = db, name = "Student", value = "student.csv", row.names = FALSE, header = TRUE)
dbWriteTable(conn = db, name = "Class", value = "class.csv", row.names = FALSE, header = TRUE)
dbWriteTable(conn = db, name = "School", value = "school.csv", row.names = FALSE, header = TRUE)

dbListTables(db)                         # The tables in the database
dbListFields(db, "School")               # The columns in a table
dbReadTable(db, "School")                # The data in a table; or,
dbGetQuery(db, "SELECT * from School")   # The data in a table

# Note the entries for SchSize. 
# I think the problem is to do with line endings.
# One solution is to read the csv file into R as dataframes,
# then import the dataframes into the database. 
dbRemoveTable(db, "School")   # Remove the tables
dbRemoveTable(db, "Class")
dbRemoveTable(db, "Student")

School <- read.csv("school.csv")  # Read csv files into R
Class <- read.csv("class.csv")
Student <- read.csv("student.csv")

# Import dataframes into database
dbWriteTable(conn = db, name = "Student", value = Student, row.names = FALSE)
dbWriteTable(conn = db, name = "Class", value = Class, row.names = FALSE)
dbWriteTable(conn = db, name = "School", value = School, row.names = FALSE)

dbListTables(db)                 # The tables in the database
dbListFields(db, "School")       # The columns in a table
dbReadTable(db, "School")        # The data in a table

# Another l is to use sqldf to import the csv files - see SEGMENT 7 below.
# See: http://stackoverflow.com/a/4335739/419994


###--- SEGMENT 6 ---###
# Remove the tables in preparation for an alternative import.
dbRemoveTable(db, "School")
dbRemoveTable(db, "Class")
dbRemoveTable(db, "Student")

# An alternative:
# The data are contained in three worksheets 
# of an Excel workbook, Test.xlsx.
# The worksheets can be loaded into R as a list of dataframes 
# using functions from the XLConnect package.

wb <- loadWorkbook("Test.xlsx")
Tables <- readWorksheet(wb, sheet = getSheets(wb))

# The dataframes are imported into the database.
with(Tables, {
dbWriteTable(conn = db, name = "Student", value = Student, row.names = FALSE)
dbWriteTable(conn = db, name = "Class", value = Class, row.names = FALSE)
dbWriteTable(conn = db, name = "School", value = School, row.names = FALSE)})

dbListTables(db)                 # The tables in a dataframe
dbListFields(db, "School")       # The columns in a table
dbReadTable(db, "School")        # The data in a table

# Close the connectioon to the database and tidy-up
dbDisconnect(db)                             # Close connection
rm(list = c("Class", "School", "Student"))   # Remove dataframes


###--- SEGMENT 7 ---###
# Using sqldf

# METHOD 1: Import the csv files

# Create an empty database.
sqldf("attach 'Test1.sqlite' as new")

# Import the csv files directly into the database
read.csv.sql("student.csv", sql = "create table Student as select * from file", dbname = "Test1.sqlite")
read.csv.sql("class.csv", sql = "create table Class as select * from file", dbname = "Test1.sqlite")
read.csv.sql("school.csv", sql = "create table School as select * from file", dbname = "Test1.sqlite")

sqldf("select * from sqlite_master", dbname = "Test1.sqlite")$tbl_name  # Tables in the database
sqldf("pragma table_info(School)", dbname = "Test1.sqlite")$name        # Columns in the School table
sqldf("select * from School", dbname = "Test1.sqlite")                  # Data in the School table


# METHOD 2: Use XLConnect to read in the sheets of the Excel workbook.
wb <- loadWorkbook("Test.xlsx")
Tables <- readWorksheet(wb, sheet = getSheets(wb))

# Tables is a list of dataframes.
names(Tables)       
names(Tables) = c("stud", "cl", "sch")    # Change the names of the dataframes
# sqldf does not like table and dataframe to have the same name.

# Create an empty database.
sqldf("attach 'Test2.sqlite' as new")

# Import dataframes from Tables into database
with(Tables, {
 sqldf("create table School as select * from sch", dbname = "Test2.sqlite")
 sqldf("create table Class as select * from cl", dbname = "Test2.sqlite")
 sqldf("create table Student as select * from stud", dbname = "Test2.sqlite")})

sqldf("select * from sqlite_master", dbname = "Test2.sqlite")$tbl_name  # Tables in the database
sqldf("pragma table_info(School)", dbname = "Test2.sqlite")$name        # Columns in the School table
sqldf("select * from School", dbname = "Test2.sqlite")                  # Data in the School table




