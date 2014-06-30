# Load required packages and set the working directory
library(sqldf)      # Loads RSQLite
library(XLConnect)  # To read Excel sheets and workbooks


setwd('./Data')  # But modify path if alternative path needed.

# Create the database "Test1.sqlite" if one already exists.
db <- dbConnect(SQLite(), dbname="Test1.sqlite")

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

dbSendQuery(conn = db, 
            "INSERT INTO School
         VALUES (4, 'temp', 'state', 'huge')")

#check the work
dbListTables(db)                         # List the tables in the database
dbListFields(db, "School")               # List the columns in a table
dbReadTable(db, "School")                # Display the data in a table method1
dbGetQuery(db, "SELECT * from School")   # Display the data in a table method2





