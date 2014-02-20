[![Gem Version](https://badge.fury.io/rb/vardb.png)](http://badge.fury.io/rb/vardb)

#Vardb

##Introduction
This gem exists to create PostgreSQL or SQLite databases from .matrix files and associated metadata spreadsheets. This gem will create a metadata table based upon the column headers in the given excel file. However, there are some simple best practices to consider when making your Excel spreadsheet: 

1. Every column should have a header
2. Each row should have some data in the first column, it's ok to have blanks after that 
3. There shouldn't be duplicate column names
4. It's best to avoid characters like "(", ")", "-" and whitespace in column names 
5. The gem loads the first sheet only so if you have a workbook of sheets they need to be broken out into separate .xls files or merged into one table.

##Example Usage
###Give Vardb your Database connection details
```ruby
db = Vardb.new
```

```ruby
db.set_connection(:host => '', :port => '', :dbname => '', :user => '', :password => '')
```
                     
###Tell Vardb what .matrix file you want to load
```ruby
db.set_matrix('/Users/username/file.matrix')
```        

###Tell Vardb what Excel spreadsheet you want to load
```ruby
db.set_metadata('/Users/username/metadata.xls')
```                                          

###Build a Schema from the .matrix file and pass either a 'pg' or 'sqlite' argument depending on the type of database you wish to build
```ruby
db.format_matrix('pg')
```                     

###Populate the database form your .matrix file                     
```ruby
db.populate_matrix('pg')
```

###Build a Schema from your spreadsheet
```ruby
db.format_metadata('pg')
```
                     
###Populate the database from your spreadsheet
```ruby
db.populate_metadata('pg')
```

##….And that's all!
###Now you have a PostgreSQL database from your files