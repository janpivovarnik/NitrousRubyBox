require 'sequel'
require 'jdbc/dss'
require 'rinruby'
require 'csv'
require './util.rb'
require 'gooddata'
#require '~/login.rb'

root_dir = "."

GoodData.logging_on

begin
  Jdbc::DSS.load_driver
  Java.com.gooddata.dss.jdbc.driver.DssDriver

  ads_url = "jdbc:dss://na1.secure.gooddata.com/gdc/dss/instances/#{$SCRIPT_PARAMS["ADS_ID"]}"

# Train the model (spit out the rfmodel.rmd)

  extract_from_ads(ads_url, $SCRIPT_PARAMS["USERNAME"], $SCRIPT_PARAMS["PASSWORD"], "#{root_dir}/tmp/alldata.csv",
                   "SELECT * FROM dxvf_alldata")

  R.eval(File.read("#{root_dir}/scripts/pairedcomparisonsgrp.r"))

  R.eval("test<-read.csv('tmp/alldata.csv')")
  R.eval('PairedComparisonsGrp(test,4,
          list(seq(from=5,to=8),seq(from=9,to=14),
          seq(from=15,to=23),seq(from=24,to=25),seq(from=26,to=34)),
          c("externalities","spend","brand","seasons","pricing"))')

  CSV.open("#{root_dir}/tmp/pcg_data.csv", "w") do |csv|
    csv << ['pcgxval','pcgyval','pcgval']
    CSV.foreach("#{root_dir}/tmp/paired_comparisons_grp.csv", :headers => true) do |row|
      xval = ''
      row.each do |cell|
        if(cell[0].length == 0) then
          xval = "#{cell[1]}"
        else
          yval = "#{cell[0]}"
          val = cell[1]
          csv << [xval,yval,val]
        end
      end
    end
  end

  #execute_ddl(ads_url, $SCRIPT_PARAMS["USERNAME"], $SCRIPT_PARAMS["PASSWORD"],[
  #    "CREATE TABLE IF NOT EXISTS dxvf_pcomp_grp (xval VARCHAR(50), yval VARCHAR(50), val DECIMAL(13,2))",
  #    "TRUNCATE TABLE dxvf_pcomp_grp"
  #])

  #save_to_ads(ads_url, $SCRIPT_PARAMS["USERNAME"], $SCRIPT_PARAMS["PASSWORD"], "#{root_dir}/tmp/pcg_data.csv",
  #            "INSERT INTO dxvf_pcomp_grp(xval, yval, val) VALUES (?,?,?)")

  # upload data to project

  client = GoodData.connect $SCRIPT_PARAMS["USERNAME"], $SCRIPT_PARAMS["PASSWORD"]

  blueprint = eval(File.read('./model/model.rb')).to_blueprint
  project = client.projects($SCRIPT_PARAMS["PROJECT_ID"])

  GoodData::Model.upload_data('./tmp/pcg_data.csv', blueprint, 'pcg', :client => client, :project => project )


rescue => e
  puts e
  puts e.backtrace.join "\n"
end