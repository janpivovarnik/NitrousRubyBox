IThis example contains Ruby scripts that set up and execute the random forest method data prediction.

HOW TO STEPS
------------

1) Create the login.rb file with this content in your HOME directory

                     $SCRIPT_PARAMS = {
                          "ADS_ID" => "",
                          "USERNAME" => "",
                          "PASSWORD" => "",
                          "PROCESS_ID" => "",
                          "PROJECT_ID" => ""
                      }

   Put your GoodData platform USERNAME and PASSWORD paramaters in this file.

2) Go to secure.gooddata.com/gdc/projects/ and create a new GoodData project. Put the new PROJECT_ID into the login.rb file.

3) Go to https://secure.gooddata.com/gdc/dss/instances and create a new ADS instance. Put the new ADS_ID into the login.rb file.

4) Leave the PROCESS_ID blank

5) Run setup_ldm.rb script. Look into the newly created GoodData project's LDM model.

6) Run setup.rb script. Go to the DIC console and see the newly deployed process in the new project. Put the the new
   PROCESS_ID into the login.rb file. Add the ADS_ID, USERNAME, PASSWORD (secure parameter), and PROJECT_ID parameters to
   the process schedule.

7) Run the process schedule and see the data populated in the new project. Create a simple line chart with the SUM(value)
   metric and week attribute on the X axis to see the historical and predicted dats.


FILES
-----

data/model.csv - this is the original historical data file that is used for the model training purposes. This file is
                 only used during the setup phase (setup.rb) when the data are loaded to the ADS(to the dxvf_model table).
                 The processing expects that the dxvf_model table contains current model data. The predict.rb process
                 downloads the copy of the dxvf_model table to the tmp/model.csv temporary local file for the R
                 processing.

data/scenario.csv - this is the original historical data file that is used for the model prediction purposes. This file
                    is only used during the setup phase (setup.rb) when the data are loaded to the ADS(to the
                    dxvf_scenario table). The processing expects that the dxvf_scenario table contains latest data.
                    The predict.rb process downloads the copy of the dxvf_scenario table to the tmp/scenario.csv
                    temporary local file for the R processing.

log/*.txt   - various log files

model/model.rb - GoodData Ruby SDK project blueprint (contains a LDM of the target project)

scripts/train.r - R script that is executed by the predict.rb script during the training phase. This script takes the
                  data from the ADS dxvf_model table, stores it locally in the tmp/model.csv and creates the random
                  forest R tree object scripts/rfmodel.rmd that is going to be used for the prediction.

scripts/predict.r - R script that is executed by the predict.rb script during the prediction phase. This script takes the
                    data from the ADS dxvf_scenario table, stores it locally in the tmp/scenario.csv, loads the trained
                    random forest object and uses it for paym variable prediction. The result data are stored in the
                    tmp/score.csv file

scripts/rfmodel.rmd - the actual trained random forest model tree R object (created on fly via the scripts/train.r R script)


sql/model.sql - SQL that creates the training data table in the ADS

sql/scenario.sql - SQL that creates the prediction source data table in the ADS

tmp/data.csv - generated file that contains the merged dxvf_scenario and predicted data (tmp/score.csv). This file is
               written to the GoodData datamart

tmp/model.csv - data retrieved from the dxvf_model table (used for the local R processing - random forest training)

tmp/scenario.csv - data retrieved from the dxvf_scenario table (used for the local R processing - random forest
                   prediction)

tmp/score.csv - data local R processing result data - prediction

setup.ldm - local script that sets up the ADS environment (creates and populates the dxvf_scenario and dxvf_model tables).
            This script also deploys and schedules the predict.rb script on the GoodData platform. Please note that you
            still must add the following parameters to the schedule

                ADS_ID - ADS ID
                USERNAME - GoodData username
                PASSWORD - GoodData password
                PROJECT_ID - GoodData project ID (project must be created before running the setup.rb via
                             secure.gooddata.com/gcs/projects

            NOTE: the setup.rb is executed on your local computer and requires all parameters above in the login.rb file
                  located in your HOME directory in this format

                  $SCRIPT_PARAMS = {
                      "ADS_ID" => "xxxxxxx",
                      "USERNAME" => "zd@gooddata.com",
                      "PASSWORD" => "yyyyyyyy",
                      "PROCESS_ID" => "",
                      "PROJECT_ID" => "zzzzzzzzz"
                  }

setup.ldm - creates the LDM model in an pre-created GoodData project.

             NOTE: the setup.rb is executed on your local computer and requires all parameters above in the login.rb file
                   located in your HOME directory in this format

                   $SCRIPT_PARAMS = {
                        "ADS_ID" => "xxxxxxx",
                        "USERNAME" => "zd@gooddata.com",
                        "PASSWORD" => "yyyyyyyy",
                        "PROCESS_ID" => "",
                        "PROJECT_ID" => "zzzzzzzzz"
                   }

util.rb - various Ruby utilities (used by all other Ruby scripts)

predict.rb - the main prediction script that is scheduled on the GoodData platform. This script retrieves data from the
             ADS and executes the scripts/train.r and scripts/predict.r R scripts. Then it loads the result data into
             the GoodData project.


TROUBLESHOOTING
---------------

Reach ZD (Zdenek Svoboda) at zd@gooddata.com or at +420 777 640 979.