Gem::Specification.new do |s|
	s.name	=	'vardb'
	s.version	=	'0.0.2'
	s.summary	=	"Variant database builder"
	s.description	=	"This gem builds PostgreSQL databases from .matrix files and metadata spreadsheets"
	s.author	=	["Peter McCaffrey"]
	s.email	=	["peter@accetia.com"]
	s.files	=	["lib/vardb.rb", "lib/vardb/snp_db_build.rb", "lib/vardb/database_populator.rb", "lib/vardb/xls_parser.rb", "lib/vardb/snpscript_configdata.rb"]
	s.homepage	=	''
	s.license	=	''

	#specify dependencies
	s.add_runtime_dependency "pg", "~> 0.17.0"
	s.add_runtime_dependency "roo", "~> 1.13.0"
	s.add_runtime_dependency "sqlite3", "~> 1.3.7"
end