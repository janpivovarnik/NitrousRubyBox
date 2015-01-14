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

  extract_from_ads(ads_url, $SCRIPT_PARAMS["USERNAME"], $SCRIPT_PARAMS["PASSWORD"], "#{root_dir}/tmp/model.csv",
                   "SELECT * FROM dxvf_model")

  R.eval(File.read("#{root_dir}/scripts/train.r"))

# Predict the sales

  extract_from_ads(ads_url, $SCRIPT_PARAMS["USERNAME"], $SCRIPT_PARAMS["PASSWORD"], "#{root_dir}/tmp/scenario.csv",
                 "SELECT * FROM dxvf_scenario")

  R.eval(File.read("#{root_dir}/scripts/predict.r"))

  execute_ddl(ads_url, $SCRIPT_PARAMS["USERNAME"], $SCRIPT_PARAMS["PASSWORD"],[
    "CREATE TABLE IF NOT EXISTS dxvf_score (week INT, score DECIMAL(17,4))",
    "TRUNCATE TABLE dxvf_score"
  ])

# Save the prediction back to ADS

  #save_to_ads(ads_url, $SCRIPT_PARAMS["USERNAME"], $SCRIPT_PARAMS["PASSWORD"], "#{root_dir}/tmp/score.csv",
  #                 "INSERT INTO dxvf_score(week, score) VALUES (?,?)")



# create data.csv for upload

  CSV.open("#{root_dir}/tmp/data.csv", "w") do |csv|
    csv << ['week_id','score','value']
    last_week = 0
    last_date = 0
    CSV.foreach("#{root_dir}/tmp/scenario.csv", :headers => true) do |row|
      last_week = row['week'].to_i
      last_date = Date.parse row['date']
      csv << [last_week,last_date.strftime('%d/%m/%Y'),row['paym']]
    end
    CSV.foreach("#{root_dir}/tmp/score.csv", :headers => true) do |row|
      last_date = last_date + 7
      csv << [row[0].to_i+last_week,last_date.strftime('%d/%m/%Y'),row[1].to_i]
    end
  end

# upload data to project

  client = GoodData.connect $SCRIPT_PARAMS["USERNAME"], $SCRIPT_PARAMS["PASSWORD"]

  blueprint = eval(File.read('./model/model.rb')).to_blueprint
  project = client.projects($SCRIPT_PARAMS["PROJECT_ID"])

  GoodData::Model.upload_data('./tmp/data.csv', blueprint, 'score', :client => client, :project => project )

rescue => e
  puts e
  puts e.backtrace.join "\n"
end