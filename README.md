# BehavFlow: automating aspects of rodent behavior testing

![](./automateBehaviorWorkflow.svg)


## Setup
* Use a relational database (SQLite) to store animal records, experimental treatment, and metadata.
* Use cloud storage to synchronize experimental schedules and data files across all computers
* Create a local user on Windows to install Dropbox and run MedPC so that it is not specific to one technician 
* Use a Linux Server on campus to run services that monitor dropbox folders to convert file formats, run analysis, and generate notifications.
* Use an off campus server (outside of firewall) to work with a messaging system (Slack) to convert user input into data in standard format and send notifications

## Services
* Convert Spreadsheet to MedPC macros for each session and all individual rats. A pdf file is also generated for record keeping
* Generate notifications when each operant run is finished
* Extract MedPC data into Spreadsheet, add session number
* Generate notifications when change in operant schedules are needed (e.g. dose, extinction, reinstatement)
* Generate warnings on exceptions (e.g body weight loss, unrealistic body weights, multiple animals have exactly same body weights).
* Generate daily schedule changes in the format that can be pasted into the Spreadsheet.
* Generate “notes” that can be pasted into slack once some procedures are done (e.g. Baytril).
* Generate reminders for starting experiments (until the experiment is started, i.e, data files exist)
* Generate reminders for missing data in database (e.g. DOW, assignment of experiment treatment)
* Update database when certain procedures are done (e.g. Brevital test)
* Maintain a log of periodic tasks (prepare drugs, cleaning chambers, etc.)
* We still have one manually maintained Spreadsheet for experiment planning.

## Advantages
* Reducing experimental error 
* Convert user friendly format (Spreadsheet) to machine loadable exp file in MedPC.
* “Macros” and pdf files are archived automatically.
* Use foreign key in database
* Check against existing animal ID in the /note app
* Automatic reminder of schedule change
* Automatic check against common errors
* Automatic check for missing information
* Automatic database entry from notes entered in browser
* Standardized experimental record for miscellaneous notes for each animal
* Entered on a computer or smartphone
* Animal ID verified. 
* Name of technician and dates are automatically recorded

## Disadvantages
* Somewhat fragile (many components)
* Need backup plan when system is down
* Need programming skills 
* Still several manual processes (e.g. schedule change still needs to be copy-pasted).


