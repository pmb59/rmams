#' Validate mams object
#' @description Internal check function to determine if all necessary MAMS object slots
#' exist within the object
#' @param mams_object Input MAMS object to be checked
#' @export 
check_MAMS <- function(mams_object){
    #Check 1. Check to see all classes exist in the object
    #The following classes are required for each MAMS object:
    all_possible_classes = c("FOM", "ONG", "FEA", "OBS", "FID", "OID", "REC", "FNG")
    if(!all(all_possible_classes %in% methods::slotNames(mams_object))){
        
        missing_classes <- paste(all_possible_classes[which(!all_possible_classes %in% methods::slotNames(mams_object))], collapse = ', ')
        
        stop(paste("The following classes are missing from the MAMS object:", missing_classes))
    }
    
    
    #Check 2. Check to see all required fields for each MAMS class (FOM, ONG, etc.) exist
    required_field_list = list(FOM = c("id", "dataset_id", "data_type", "analyte"),
                               ONG = c("filepath", "accessor"),
                               FEA = c("filepath", "accessor"),
                               OBS = c("filepath", "accessor"),
                               FID = c("filepath","accessor"),
                               OID = c("filepath","accessor"),
                               REC = c("record_function_name","record_package_name", "record_package_version"),
                               FNG = c())
    
    
    warn_field_list = list(FOM = c("filepath","accessor","representation","representation_description","obs_unit","processing","processing_description",
                                   "analyte","analyte_description","modality","obs_subset","obs_subset_description","feature_subset","feature_subset_description",
                                   "record_id","parent_id","parent_relationship","parent_relationship_description","oid","fid","obs", "fea"),
                           ONG = c("parent_id","record_id","edge_metric","metric_type"),
                           FEA = c("feature_modality"),
                           OBS = c("filepath","accessor"),
                           FID = c(),
                           OID = c(),
                           REC = c(),
                           FNG = c())
    
    
    
    
    
    
    
    
    #Q1. What ID do I refer to when returning error message?
    #Q2. What is the correct way for the user to input the missing information?
    
    for(mams_class in all_possible_classes){
        slot_obj_all <- methods::slot(mams_object, mams_class)
        # get all foms/fngs etc
        list_of_obj <- names(slot_obj_all)
        if(length(list_of_obj) == 0){
            warning(paste("The following slot is empty:", mams_class))
        }
        
        else{
            
            list_of_missing_ids<-list()
            list_of_missing_fields<-list()
            list_of_warning_fields<-list()
            
            # iterate over all foms
            for(i in 1:length(list_of_obj)){
                id = list_of_obj[i]
                slot_obj <-slot_obj_all[id]
                
                # Check if ids itself is missing - id, datasetid etc        
                check_missing_ids<- lapply(slot_obj, function(x){
                    missing_ids <- c()
                    listobj<- SeuratObject::S4ToList(x)
                    current_fields <- names(listobj)
                    if(!all(required_field_list[[mams_class]] %in% current_fields)){
                        missing_ids = required_field_list[which(!required_field_list[[mams_class]] %in% current_fields)]
                    }
                    else{
                        missing_ids = NULL
                    }
                    
                    if(!is.null(missing_ids)){
                        return(missing_ids)
                    }else{
                        return("")
                    }
                })
                
                # check if the the value of id is missing (example dataset id slot is present but the value is NA)
                check_missing_fields<- lapply(slot_obj, function(x){
                    missing_fields <- c()
                    for(fields in required_field_list[[mams_class]]){
                        
                        for (multi in methods::slot(x, fields)) { 
                            
                        if (is.na(multi) | multi == ""){
                            missing_fields <- c(missing_fields, fields)
                        }
                        }
                        
                    }
                    if(!is.null(missing_fields)){
                        return(missing_fields)
                    }else{
                        return("")
                    }
                })
                
                # check if we are missing anything from fields that are not required but needs a warning
                check_warning_fields<- lapply(slot_obj, function(x){
                    warning_fields <- c()
                    for(fields in warn_field_list[[mams_class]]){
                        lst <- list(methods::slot(x, fields))
                        #methods::slot(x, fields) %in% c("","NA")
                        for (t in methods::slot(x, fields)){
                            if(is.null(t)){
                           # print(fields)
                                warning_fields <- c(warning_fields, fields)
                            }
                            else if(is.na(t) | t == "") {
                                    warning_fields <- c(warning_fields, fields)
                                }
                        }
                        
                    }
                    if(!is.null(warning_fields)){
                        return(warning_fields)
                    }else{
                        return("")
                    }
                    
                })  
                
                # Add items to the final list only if they aren't empty
                
                if(!all(check_missing_fields[[id]] == "")){
                    list_of_missing_fields[id]<-check_missing_fields
                }
                
                if(!all(check_missing_ids[[id]] == "")){    
                    list_of_missing_ids[id]<-check_missing_ids
                }    
                
                if(!all(check_warning_fields[[id]] == "")){    
                    list_of_warning_fields[id]<-check_warning_fields
                }  
            }
            
            
            
            # Prepare to print warnings/errors if the lists aren't empty
            if(length(list_of_warning_fields)!=0){
                message("Warning: Please use the setter functions to add the missing field information for the following slots: \n(Ex. If missing 'filepath' for fom1, then 'fom(mams = mams_object, fom_id = 'fom1', key = 'filepath') <- ...')\n:")
                for (i in names(list_of_warning_fields)){
                     warning(paste0(i,' is missing the fields:',''))
                     warning(paste0(for(j in list_of_warning_fields[i]){print(j)},'\n'))
                }
            }
            
            if(length(list_of_missing_ids)!=0){
                
                message("Error: Please use the setter functions to add the missing field information for the following slots: \n(Ex. If missing 'filepath' for fom1, then 'fom(mams = mams_object, fom_id = 'fom1', key = 'filepath') <- ...')\n:")
                for (i in names(list_of_missing_ids)){
                    stop(paste0(i,' is missing the fields:',''))
                    stop(paste0(for(j in list_of_missing_ids[i]){print(j)},'\n'))
                }
             #   stop(paste0(paste0(names(list_of_missing_ids), ' is missing the field(s): ','\n',list_of_missing_ids, '\n')))
            }
            
            
            if(length(list_of_missing_fields)!=0){
                message("Error: Please use the setter functions to add the missing field information for the following slots: \n(Ex. If missing 'filepath' for fom1, then 'fom(mams = mams_object, fom_id = 'fom1', key = 'filepath') <- ...')\n:")
                for (i in names(list_of_missing_fields)){
                    warning(paste0(i,' is missing the fields:',''))
                    warning(paste0(for(j in list_of_missing_fields[i]){print(j)},'\n'))
                }
              #  stop(paste0(paste0(names(list_of_missing_fields), ' is missing the field(s): ',for(i in list_of_missing_fields){print (paste(i))}, '\n')))
                
            }
            
            else if ( all(lengths(c(list_of_warning_fields,list_of_missing_ids,list_of_missing_fields))) %in% c(0)) {
                #If passes to here, all clear
                message("All clear!")
            }
            
        }
    }
   
}
