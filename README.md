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
###Now you have a database from your files

##2. Analysis (this is in early development)
###Test your database for snp/phenotype associations
With the parameters described below, this method iteratively submits every possible combination of snps and phenotypes provided to a test for significant association. To do so, it simply calculates two things: the **association support** and **association confidence** for a given snp/phenotype association rule. A great article explaining this can be found <a href="http://www-users.cs.umn.edu/~kumar/dmbook/ch6.pdf">here</a>. 

An association's **support** is simply the number of samples with BOTH the snp AND the phenotype divided by the total number of samples. An association's **confidence** is simply the number of samples that have BOTH the snp AND the phenotype (as above) divided by the number of samples that have the snp. And that's it. If those calculations both pass the specified minimum cutoffs provided (see below), then the association rule is flagged and returned as a result.

The ```test_association ``` method accepts 4 parameters:

1. snps [ ]: an array of snps
2. phenotype: hash where the keys and values represent phenotypes. These are determined by the columns and values in your metadata spreadsheet. Say you have a column called "penicillinresistance" and the values in that column's cells were things like "susceptible" or "resistant". An appropriate phenotype hash to test for an association would therefore be ```:penicillinresistance => 'resistant' ```
3. minimum support: this is the minimum cutoff for the frequeny of the association amongst the whole pool of samples
4. minimum confidence: this is the minimum cutoff for the confidence of the relationship

```ruby
db.test_association([1, 2, 5674, 272, 98790], {:penicillinresistance => 'resistant'}, 0.4, 0.5)
```

The output from this command is a hash of significant associations. The format of this hash is as follows:
```ruby
[snp_id, phenotype_key, phenotype_value] => [ calculated_support, calculated_confidence]
```

like so:

``` ruby
["16", "penicillinresistance", "resistant"] => [ "0.544", "0.672"]
```

Thus, the results can be parsed as needed. Just one thing to point out from above, this method both accepts and outputs snp_id's not snp loci.