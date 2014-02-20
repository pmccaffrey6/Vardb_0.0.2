require_relative 'xls_parser'
require 'pg'

module Populator
  include XlsParser

  def populate_matrix(type)

	host = ConfigData.get_connection

	if type == 'pg'
		#PG Connection
		conn = PGconn.connect(:host => host[:host], :port => host[:port], :dbname => host[:dbname], :user => host[:user], :password => host[:password])
	
		#Matrix File PG Command Preparation
		conn.prepare('load_snps', 'INSERT INTO snps (id, locus, annotation_id) values ($1, $2, $3)')
		conn.prepare('load_annos', 'INSERT INTO annotations (id, cds, transcript, transcript_id, info, orientation, cds_locus, codon_pos, codon, peptide, amino_a, syn ) values ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)')
		conn.prepare('load_samples_snps', 'INSERT INTO samples_snps (sample_id, snp_id) values ($1, $2)')
		conn.prepare('load_samples', 'INSERT INTO samples (id, name) values ($1, $2)')

	elsif type == 'sqlite'
		#SQLite Connection
		db = SQLite3::Database.new "sqlite_db/#{host[:dbname]}.db"

	end



	#Matrix File Load-ins
	text=File.open(ConfigData.get_matrix).read

	linenum = 1
	sample_number = 1

	snps = []
	anno_tabs = []
	anno_vals = []

	text.each_line do |line|
		(header, line_data) = line.split(' ', 2)
		if (header == '#snp_pos')
			puts "populating snps table..."
			snps = line_data.split("\t")
			snp_counter = 1
			snps.each do |locus|
				if type == 'pg' 
					conn.exec_prepared('load_snps', [snp_counter, locus, snp_counter])
				elsif type == 'sqlite'
					db.execute("INSERT INTO snps (id, locus, annotation_id) VALUES (?,?,?)", [snp_counter, locus, snp_counter])
				end
				snp_counter += 1
			end	
		elsif (header == '#annotation')
			puts "populating annotations table..."
			anno_tabs = line_data.split("\t")
			anno_tabs.each { |tab| anno_vals << tab.split(',', 11) }
			anno_counter = 1
        	anno_vals.each do |anno|
    	    	anno.insert(0, anno_counter)
    	    	if anno[1].match('intergenic')
    	    		if type == 'pg'
    		    		conn.exec_prepared('load_annos', [ anno[0], 0, 0, 0,  anno[1], 0, 0, 0, 0, 0, 0, 0 ])
    		    	elsif type == 'sqlite'
    		    		db.execute("INSERT INTO annotations (id, cds, transcript, transcript_id, info, orientation, cds_locus, codon_pos, codon, peptide, amino_a, syn ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)", [ anno[0], 0, 0, 0,  anno[1], 0, 0, 0, 0, 0, 0, 0 ])
    		    	end
            	else 
            		if type == 'pg'
                		conn.exec_prepared('load_annos', [ anno[0], anno[1], anno[2], anno[3], anno[4], anno[5], anno[6], anno[7], anno[8], anno[9], anno[10], anno[11] ])
                	elsif type == 'sqlite'
                		db.execute("INSERT INTO annotations (id, cds, transcript, transcript_id, info, orientation, cds_locus, codon_pos, codon, peptide, amino_a, syn ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12)", [ anno[0], anno[1], anno[2], anno[3], anno[4], anno[5], anno[6], anno[7], anno[8], anno[9], anno[10], anno[11] ])
                	end	
            	end
            	anno_counter += 1  
        	end
		else
			if sample_number == 1 then
		    	puts "loading reference..."
	    	else
		    	puts "loading in sample #{sample_number - 1}..."
			end
			if type == 'pg'
				conn.exec_prepared('load_samples', [sample_number, header])
			elsif type == 'sqlite'
				db.execute("INSERT INTO samples (id, name) VALUES (?,?)", [sample_number, header])
			end
			line_data.split("\t").each_with_index do |n, i|
				if (n == '1')
					if type == 'pg'
						conn.exec_prepared('load_samples_snps', [sample_number, i])
					elsif type == 'sqlite'
						db.execute("INSERT INTO samples_snps (sample_id, snp_id) VALUES (?,?)", [sample_number, i])
					end
				end
  	    	end
  	    	sample_number += 1
		end
    	linenum += 1
	end
  end	

  def populate_metadata(type)

  	host = ConfigData.get_connection

	#Excel Spreadsheet Command Preparaton
	metadata_fields = XlsParser.load_meta_fields(ConfigData.get_metadata)

	metadata_fields_string = "id "

	metadata_fields.each do |item|
		metadata_fields_string << item
	end

	metadata_values_string = "$1 "

	metadata_fields.length.times do |i|
    	metadata_values_string << ", $#{i+2}"
	end

	if type == 'pg'
		#PG Connection
		conn = PGconn.connect(:host => host[:host], :port => host[:port], :dbname => host[:dbname], :user => host[:user], :password => host[:password])
		conn.prepare('load_metadata', "INSERT INTO sample_metadata (#{metadata_fields_string}) values (#{metadata_values_string})")
	elsif type == 'sqlite'
		#SQLite Connection
		db = SQLite3::Database.new "sqlite_db/#{host[:dbname]}.db"
	end

	#Excel Spreadsheet Load-ins
	s = Roo::Excel.new(ConfigData.get_metadata)
	s.default_sheet = s.sheets.first

	row = 2

	puts "populating sample metadata..."

	until s.cell(row, 1).nil?
		row_contents = ["#{row-1}"]
		metadata_fields.length.times do |i|
			row_contents << "#{s.cell(row, i)}"
		end
		if type == 'pg'
			conn.exec_prepared('load_metadata', row_contents)
		elsif type == 'sqlite'
			db.execute("INSERT INTO sample_metadata (#{metadata_fields_string}) VALUES (#{metadata_values_string})", row_contents)
		end
		row += 1
	end
  end
end  