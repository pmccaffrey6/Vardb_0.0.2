require 'roo'

module XlsParser
    ## A few rules about Excel files:
    ## 1. .xls only, this can't accept .xlsx
    ## 2. There should be no empty cells in the header row of a sheet (first row)
    ## 3. For good form, there shouldn't be any subsequent rows that are 
    ##    longer than the header row
    ## 4. There should not be any duplicate cell names in the header row	
	def XlsParser.load_meta_fields(file)
		s = Roo::Excel.new(file)
		s.default_sheet = s.sheets.first

		columns = 1
		until s.cell(1, columns).nil?
			columns += 1
		end

		counter = 1

		metadata_fields = []

		columns.times do |counter|
		    if s.cell(1, counter).nil?
		    	metadata_fields << ", empty#{counter}"
		    else 
  			    metadata_fields << ", #{s.cell(1, counter).to_s.gsub(/\s+/, "").gsub("-","").gsub("(","").gsub(")","").gsub(".","").gsub("/","")}"
  			end
  			counter += 1
		end

		return metadata_fields
	end
end