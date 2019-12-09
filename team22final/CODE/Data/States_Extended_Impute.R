library(dplyr)
require(tidyverse)
library(e1071)
library(zoo)
library(tidyr)
states_ext <- read.csv('New_Columns_Raw.csv',header=T)
test_states <- data.frame(states_ext)
states <- unique(states_ext$state)
fullcols = colnames(states_ext)[4:51]
lm_cols <- c('fouryear_tuition',
              'twoyear_tuition',
              'grad_rate',
              'foodstamp_rep',
              'povrate',
              'ideo_cit',
              'pollib_lower',
              'pollib_median',
              'pollib_upper',
              'foreign_born',
              'soc_capital_ma',
              'pop_govhealthins',
              'pop_nohealthins',
              'anti_education',
              'ideo_state',
              'neutral_education',
              'party_state',
              'pro_education')
avg_cols <- c('avg_att_rate',
              'avg_daily_att_total',
              'dropout_rate',
              'enroll_students_public',
              'policy_mood',
              'innovatescore',
              'health_rank',
              'quality_of_life_rank')
last_cols <- c('charterschoolslaw',
               'evol_wkns_allowed',
               'taxcredit_parents',
               'homeschool_records_extent',
               'kind_att_rqd',
               'mand_lic_teach',
               'prvt_curric_control_extent',
               'stnd_testing_rqd',
               'teacher_qual_rqd',
               'comp_years')

states_imp <- states_ext %>% group_by(state) %>%
  mutate(health_rank=ifelse(is.na(health_rank),mean(health_rank,na.rm=TRUE),health_rank),
         avg_att_rate=ifelse(is.na(avg_att_rate),mean(avg_att_rate,na.rm=TRUE),avg_att_rate),
         avg_daily_att_total=ifelse(is.na(avg_daily_att_total),mean(avg_daily_att_total,na.rm=TRUE),avg_daily_att_total),
         dropout_rate=ifelse(is.na(dropout_rate),mean(dropout_rate,na.rm=TRUE),dropout_rate),
         enroll_students_public=ifelse(is.na(enroll_students_public),mean(enroll_students_public,na.rm=TRUE),enroll_students_public),
         policy_mood=ifelse(is.na(policy_mood),mean(policy_mood,na.rm=TRUE),policy_mood),
         innovatescore=ifelse(is.na(innovatescore),mean(innovatescore,na.rm=TRUE),innovatescore),
         quality_of_life_rank=ifelse(is.na(quality_of_life_rank),mean(quality_of_life_rank,na.rm=TRUE),quality_of_life_rank)
         )

#for state in states
#for col in int_cols 
##Fit lm for col~year
##JUST FOR lm_variables
implist = list()
i=1
for(st in states) {
  temp_state_df = test_states[test_states$state == st,]
  print(nrow(temp_state_df))
  for (col in lm_cols) {
    print(col)
    if (all(is.na(temp_state_df[,col]))) {
      temp_mut <- temp_state_df %>% group_by(state) %>% 
        mutate(!!col:=0)
      temp_state_df[,col] = temp_mut[,col]
    }
    else {
      temp_fit = lm(as.formula(paste(col,"year",sep="~")),data=temp_state_df)
      temp_mut <- temp_state_df %>% group_by(state) %>% 
        mutate(!!col:=ifelse(is.na(temp_state_df[,col]),predict(temp_fit,data.frame(year=year)),temp_state_df[,col]))
      temp_state_df[,col] = temp_mut[,col]
      }
  }
  #print(nrow(temp_state_df))
  implist[[i]] <- temp_state_df
  i = i+1
}
new_states <- do.call(rbind,implist)





##FOR ALL variables
implist_all = list()
i=1
for(st in states) {
  temp_state_df = test_states[test_states$state == st,]
  #print(nrow(temp_state_df))
  for (col in fullcols) {
    #print(col)
    if (col %in% lm_cols) {
      if (all(is.na(temp_state_df[,col]))) {
        temp_mut <- temp_state_df %>% group_by(state) %>% 
          mutate(!!col:=0)
        temp_state_df[,col] = temp_mut[,col]
      }
      else {
        temp_fit = lm(as.formula(paste(col,"year",sep="~")),data=temp_state_df)
        temp_mut <- temp_state_df %>% group_by(state) %>% 
          mutate(!!col:=ifelse(is.na(temp_state_df[,col]),predict(temp_fit,data.frame(year=year)),temp_state_df[,col]))
        temp_state_df[,col] = temp_mut[,col]
      }
    }
    else if (col %in% avg_cols) {
      if (all(is.na(temp_state_df[,col]))) {
        temp_mut <- temp_state_df %>% group_by(state) %>% 
          mutate(!!col:=0)
        temp_state_df[,col] = temp_mut[,col]
      }
      else {
        temp_mut <- temp_state_df %>% group_by(state) %>% 
          mutate(!!col:=ifelse(is.na(temp_state_df[,col]),mean(temp_state_df[,col],na.rm=TRUE),temp_state_df[,col]))
        temp_state_df[,col] = temp_mut[,col]
      }
    }
    # else if (col %in% last_cols) {
    #   if (all(is.na(temp_state_df[,col]))) {
    #     temp_mut <- temp_state_df %>% group_by(state) %>% 
    #       mutate(!!col:=0)
    #     temp_state_df[,col] = temp_mut[,col]
    #   }
    #   else {
    #     temp_mut <- temp_state_df %>% group_by(state) %>% 
    #       fill(temp_state_df[,col], .direction="down")
    #     temp_state_df[,col] = temp_mut[,col]
    #   }
    # }
    else {
      next
    }
    
  }
  #print(nrow(temp_state_df))
  implist_all[[i]] <- temp_state_df
  i = i+1
}
new_states_all <- do.call(rbind,implist_all)


write.csv(new_states_all,"new_states_all.csv")
