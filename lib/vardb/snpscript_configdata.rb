module ConfigData

  @@host = {}
  @@metadata_file = ''
  @@matrix_file = ''
	
	#host connection
  def set_connection(connection_hash)
    @@host = { 
      :host => "#{connection_hash[:host]}", 
  	  :port => "#{connection_hash[:port]}", 
  	  :dbname => "#{connection_hash[:dbname]}", 
  	  :user => "#{connection_hash[:user]}", 
  	  :password => "#{connection_hash[:password]}",  
  	}
    puts "connection details: #{@@host}"
  end

  def self.get_connection
    @@host
  end

  #metadata file
  def set_metadata(file)
  	@@metadata_file = file
    puts "metadata file set to: #{@@metadata_file}"
  end

  def self.get_metadata
    @@metadata_file
  end

  #matrix file
  def set_matrix(file)
  	@@matrix_file = file
    puts "matrix file set to: #{@@matrix_file}"
  end

  def self.get_matrix
    @@matrix_file
  end
end