require 'sequel'
require 'jdbc/dss'

Jdbc::DSS.load_driver
Java.com.gooddata.dss.jdbc.driver.DssDriver

def extract_from_ads(ads_url, ads_username, ads_password, csv_file, select_statement)
  CSV.open(csv_file, "w") do |csv|
    db = Sequel.connect ads_url, :username => ads_username, :password => ads_password
    dataset = db[select_statement]
    csv << dataset.columns
    dataset.each do |row|
      csv << row.values
    end
  end
end

# TBD CHANGE THIS TO COPY LOCAL !!!!

def save_to_ads(ads_url, ads_username, ads_password, csv_file, insert_statement)
  conn = Sequel.connect ads_url, :username => ads_username, :password => ads_password
  CSV.foreach(csv_file, :headers => true) do |row|
    stat = String.new(insert_statement)
    row.each do |value|
      stat.sub! '?', value[1]
    end
    conn.run stat
  end
end


def execute_ddl(ads_url, ads_username, ads_password, ddl_statements)
  Sequel.connect ads_url, :username => ads_username, :password => ads_password do |conn|
    ddl_statements.each do |statement|
      conn.run statement
    end
  end
end