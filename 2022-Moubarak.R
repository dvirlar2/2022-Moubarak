# Daphne Virlar-Knight; May 25 2022
# Converting newly added csv to dataTable, adding physical



## -- load libraries -- ##
library(dataone)
library(datapack)
library(arcticdatautils)
library(EML)



## -- general setup -- ##
# run token in console
# get nodes
d1c <- D1Client("PROD", "urn:node:ARCTIC")

# Get the package
packageId <- "resource_map_urn:uuid:616ff45a-6e49-48e9-9be6-9074d35e433d"
dp <- getDataPackage(d1c, identifier = packageId, lazyLoad=TRUE, quiet=FALSE)

# Get the metadata id
xml <- selectMember(dp, name = "sysmeta@fileName", value = ".xml")

# Read in the metadata
doc <- read_eml(getObject(d1c@mn, xml))



## -- edit attributes -- ##
# running into issues with enumerated domain
# so, I'm going to save the EDs to reassign after
veg_marker <- doc$dataset$otherEntity$attributeList$attribute[[3]]$measurementScale

burn_severity <- doc$dataset$otherEntity$attributeList$attribute[[5]]$measurementScale

# change lat/long ratio -> interval
atts <- get_attributes(doc$dataset$otherEntity$attributeList)
atts_edited <- shiny_attributes(attributes = atts$attributes)
doc$dataset$otherEntity$attributeList <- set_attributes(atts_edited$attributes)

# assign EDs back
doc$dataset$otherEntity$attributeList$attribute[[3]]$measurementScale <- veg_marker

doc$dataset$otherEntity$attributeList$attribute[[5]]$measurementScale <- burn_severity



## -- convert OE to DT -- ##
doc <- eml_otherEntity_to_dataTable(doc, 1, validate_eml = F)


## -- add physical -- ##
# Add physical to .csv file
csv_pid <- selectMember(dp, name = "sysmeta@fileName", 
                        value = "combustion_data.csv")
csv_phys <- pid_to_eml_physical(d1c@mn, csv_pid)

doc$dataset$dataTable[[3]]$physical <- csv_phys


eml_validate(doc)


