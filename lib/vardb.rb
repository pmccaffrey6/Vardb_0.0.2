require 'vardb/snp_db_build'
require 'vardb/database_populator'
require 'vardb/snpscript_configdata'

class Vardb
	include Builder
	include Populator
	include ConfigData
end