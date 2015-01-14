#!/usr/bin/env ruby

require 'sequel'
require 'jdbc/dss'
require './util.rb'
require 'gooddata'
require '~/login.rb'

root_dir = "."

GoodData.logging_on

Jdbc::DSS.load_driver
Java.com.gooddata.dss.jdbc.driver.DssDriver

ads_url = "jdbc:dss://na1.secure.gooddata.com/gdc/dss/instances/#{$SCRIPT_PARAMS["ADS_ID"]}"


execute_ddl(ads_url, $SCRIPT_PARAMS["USERNAME"], $SCRIPT_PARAMS["PASSWORD"],[
    File.read("#{root_dir}/sql/model.sql"),
    "TRUNCATE TABLE dxvf_model",
    "COPY dxvf_model FROM LOCAL '#{root_dir}/data/model.csv' WITH PARSER GdcCsvParser() SKIP 1
            EXCEPTIONS '#{root_dir}/log/model_exceptions.txt' REJECTED DATA '#{root_dir}/log/model_rejected.txt'",
    File.read("#{root_dir}/sql/scenario.sql"),
    "TRUNCATE TABLE dxvf_scenario",
    "COPY dxvf_scenario FROM LOCAL '#{root_dir}/data/scenario.csv' WITH PARSER GdcCsvParser() SKIP 1
            EXCEPTIONS '#{root_dir}/log/scenario_exceptions.txt' REJECTED DATA '#{root_dir}/log/scenario_rejected.txt'",
    File.read("#{root_dir}/sql/alldata.sql"),
    "TRUNCATE TABLE dxvf_alldata",
    "COPY dxvf_alldata FROM LOCAL '#{root_dir}/data/alldata.csv' WITH PARSER GdcCsvParser() SKIP 1
            EXCEPTIONS '#{root_dir}/log/alldata_exceptions.txt' REJECTED DATA '#{root_dir}/log/alldata_rejected.txt'"

])

client = GoodData.connect $SCRIPT_PARAMS["USERNAME"], $SCRIPT_PARAMS["PASSWORD"]
project = client.projects($SCRIPT_PARAMS["PROJECT_ID"])

if $SCRIPT_PARAMS["PROCESS_ID"].strip.length == 0
  process = project.deploy_process(".", type: 'RUBY', name: 'DataXu Vodafone Sales Predictor')
  schedule = process.create_schedule('0 2 * * *', "./predict.rb")
  puts "Scheduled the prediction daily with schedule ID '#{schedule.uri}"
else
  process = project.deploy_process(".", type: 'RUBY', name: 'DataXu Vodafone Sales Predictor', process_id: $SCRIPT_PARAMS["PROCESS_ID"])
  puts "Redeployed new process with ID '#{process.uri}'"
end




