require_relative 'xls_parser'
require 'pg'
require 'sqlite3'

module Builder
	include XlsParser
	def format_matrix(type)
		
		host = ConfigData.get_connection

		if type == 'pg'
			conn = PGconn.connect(:host => host[:host], :port => host[:port], :dbname => host[:dbname], :user => host[:user], :password => host[:password])

			puts "formatting annotations table..."
			conn.exec("CREATE TABLE annotations (id numeric(11) PRIMARY KEY, cds varchar(128), transcript varchar(128), transcript_id varchar(128), info text, orientation varchar(128), cds_locus varchar(128), codon_pos varchar(128), codon varchar(128), peptide varchar(128), amino_a varchar(128), syn varchar(128))")

			puts "formatting snps table..."
			conn.exec("CREATE TABLE snps (id numeric(11) PRIMARY KEY, locus numeric(11), annotation_id numeric(11))")

			puts "formatting samples table..."
			conn.exec("CREATE TABLE samples (id numeric(11) PRIMARY KEY, name varchar(128))")

			puts "formatting samples_snps join table..."
			conn.exec("CREATE TABLE samples_snps (sample_id numeric(11), snp_id numeric(11))")

		elsif type == 'sqlite'
			db = SQLite3::Database.new "sqlite_db/#{host[:dbname]}.db"

			puts "formatting annotations table..."
			db.execute <<-SQL
				create table annotations (
				id numeric(11) PRIMARY KEY,
				cds varchar(128),
				transcript varchar(128),
				transcript_id varchar(128),
				info text,
				orientation varchar(128),
				cds_locus varchar(128),
				codon_pos varchar(128),
				codon varchar(128),
				peptide varchar(128),
				amino_a varchar(128),
				syn varchar(128)
				);
				SQL

			puts "formatting snps table..."
			db.execute <<-SQL
				create table snps (
				id numeric(11) PRIMARY KEY,
				locus numeric(11),
				annotation_id numeric(11)
				);
				SQL

			puts "formatting samples table..."
			db.execute <<-SQL
				create table samples (
				id numeric(11) PRIMARY KEY,
				name varchar(128)
				);
				SQL

			puts "formatting sample_snps join table..."
			db.execute <<-SQL
				create table samples_snps (
				sample_id numeric(11),
				snp_id numeric(11)
				);
				SQL

		end 
	end

	def format_metadata(type)
		host = ConfigData.get_connection

		
		metadata_fields = XlsParser.load_meta_fields(ConfigData.get_metadata)

		metadata_field_names = ""

		metadata_fields.each do |name|
			name << " varchar(128)"
			metadata_field_names << name
		end

		if type == 'pg'
			conn = PGconn.connect(:host => host[:host], :port => host[:port], :dbname => host[:dbname], :user => host[:user], :password => host[:password])

			puts "formatting sample metadata table..."
			conn.exec("CREATE TABLE sample_metadata (id numeric (11) PRIMARY KEY#{metadata_field_names})")
		
		elsif type == 'sqlite'
			db = SQLite3::Database.new "sqlite_db/#{host[:dbname]}.db"

			puts "formatting sample metadata table..."
			db.execute <<-SQL
				create table sample_metadata (
					id numeric(11) PRIMARY KEY#{metadata_field_names}
				);
				SQL
		end
	end
end