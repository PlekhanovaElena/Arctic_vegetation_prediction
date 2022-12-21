################################################################################
##     Will Current Protected Areas Harbour Refugia for                       ##
##       Threatened Arctic Vegetation Types until 2050?                       ##
##                      A First Assessment                                    ##
##                      Merin Reji Chacko                                     ##
##                      Analysis Figures 1-3                                  ##
##                   Last edited: 21.12.2022                                  ##
##                   chacko.merin@gmail.com                                  ##
################################################################################
## load libraries and datasets

rm(list=ls())

library(data.table)
library(ggplot2)
library(tidyverse)

"%ni%" <- Negate("%in%") 

#this code runs based on the dataset: "zonal_histogram_results.csv"
#this dataset is freely available at the following DOI:
# www.doi.org/10.5281/zenodo.6902764

full <- fread("zonal_histogram_results.csv")

################################################################################
###
### Figure 1: Present distribution of vegetation within and outside of protected
### areas in the Arctic

#drop non-vegetated areas and subset for the present
present <- subset(full, full$Model == "Present" & !is.na(full$Area) & 
                    full$Pixels %ni% c("91", "92", "93", "99")) 
#total tundra area:
sum(subset(present, Status == "All")$Area)
#total protected tundra
sum(subset(present, Status == "Protected")$Area)
#fraction protected: 
sum(subset(present, Status == "Protected")$Area)/
  sum(subset(present, Status == "All")$Area)*100

# Fraction of protected areas 

# for unprotected, NA
present$Total <- NA
# for total, we want to know relative abundance of VT in comparison with 
# present arctic
present$Total <- ifelse(present$Status=="All",
                        sum(subset(present, Status == "All")$Area),
                        present$Total)
#for protected, we want to know relative to total protected area
present$Total <- ifelse(present$Status=="Protected",
                        sum(subset(present, Status == "Protected")$Area),
                        present$Total)

present$Relative_Abundance <- round(present$Area/present$Total*100, digit=2)
present$Relative_Abundance <- paste(present$Relative_Abundance, "%", sep="")

present$Relative_Abundance <- gsub("3.8%", "3.80%", present$Relative_Abundance)
present$Relative_Abundance <- gsub("10.3%", "10.30%", present$Relative_Abundance)
present$Relative_Abundance <- gsub("0.5%", "0.50%", present$Relative_Abundance)
present$Relative_Abundance <- gsub("2.3%", "2.30%", present$Relative_Abundance)
present$Relative_Abundance <- gsub("2.5%", "2.50%", present$Relative_Abundance)

# divide area by 1000 as our unit is 10^2 km^2

present$Area <- present$Area/1000
present$Total <- present$Total/1000 #also for the total

protected <- subset(present, present$Status == "Protected")
all <- subset(present, present$Status == "All")

ggplot(mapping=aes(Vegetation_Type, Area, fill=Group, alpha=0.1))+
  geom_bar(data=all, stat = "identity")+
  geom_bar(data=protected,stat="identity", alpha=3)+
  geom_text(data=all, aes(label = Relative_Abundance), 
            vjust = -0.2, fontface="bold", color="black")+
  geom_text(data=protected, aes(label = Relative_Abundance), 
            vjust = -0.2, fontface="bold", color="black")+
  labs(x="Vegetation type",
       y=expression(paste("Area (",10^3," ",km^2,"",sep = ")")))+
  scale_fill_manual(values=c("#9f8c5d", "#e8c970", "#eabebf", 
                             "#94b042", "#40aa9b"))+
  theme(legend.position = "none")+ 
  theme(axis.ticks.x = element_blank(),panel.grid.major.x = element_blank(),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.background = element_blank(), 
        panel.border = element_rect(colour = "black", fill=NA),
        text = element_text(size=20))

################################################################################
###
### Figure 2: Future predictions, using the "realistic scenario"

# the realistic scenario is IPSL, SSP585, 20km
# the Model column has the combination of scenarios which form each prediction 
# in the following pattern:
# treedispersalrate_climatemodel_emissionsscenario
# tree disperals: unlimited (unlim), 5km, 20km
# climate models: EC-Earth-3-Veg (e3v), IPSL-CM5 (ipsl), and MRI-CGCM3 (mri)
# emissions scenarios:SSP126 (126) and SSP585 (585)

# the following models lack predictions for some parts of the arctic due to a
# data gap, and were removed for this analysis:

full <- subset(full, full$Model %ni% c("unlim_e3v_585",
                                       "5km_e3v_585",
                                       "20km_e3v_585"))

# the realistic model: 
real_mod <- "20km_ipsl_585"

future <- subset(full, full$Group %in% c("G", "P", "S") & full$Model!="Present")
real <- subset(future, future$Model %in% c(sprintf("%s", real_mod)))
real$Area <- real$Area/1000

# now calculate the maximum and minimum envelopes from other models

large <- list()
small <- list()

veg <- unique(real$Vegetation_Type)
type <- unique(real$Status)

for (i in 1:length(veg)){
  a <- subset(future, future$Vegetation_Type==veg[i])
  
  for (j in 1:length(type)){
    b  <- subset(a, a$Status==type[j])
    
    small[[j]] <- data.frame(Vegetation_Type = veg[i],
                              Group = unique(b$Group),
                              Maximum = max(b$Area),
                              Minimum = min(b$Area),
                              Status = unique(b$Status)
    )
  }
  
  large[[i]] <- do.call(rbind, small)
}

envelopes <- do.call(rbind, large)

rm(large, small, a, b,i,j,type, veg)

#also we need realistic in here
dd <- merge(real,envelopes, by=c("Vegetation_Type", "Group", "Status"))
dd$Time <- "Future"

#we need present info as well
present <- subset(present, present$Group %in% c("G", "P", "S"))

names(dd)[names(dd) %ni% names(present)]
present$Time <- "Present"
present$Maximum <- NA
present$Minimum <- NA
names(present)[names(present) %ni% names(dd)]
present <- present[,-c(8:9)]

dd <- rbind(dd, present)
#dd <- subset(dd, dd$Status!="All")
dd$Maximum <- dd$Maximum/1000
dd$Minimum <- dd$Minimum/1000

dd$Status <- factor(dd$Status, levels = c("Unprotected", "Protected", "All"))
dd$Time <- factor(dd$Time, levels = c("Present", "Future"))
#you need time and protected to be factors

# max/min for unprotected needs to be the ones for all
# but the area for unprotected needs to stay the same

protected <- subset(dd, dd$Status=="Protected")
unprotected <- subset(dd, dd$Status=="Unprotected")  
unprotected <- unprotected[,-c(8:9)]
all <- subset(dd, dd$Status=="All")
unprotected <- cbind(unprotected, all[,c(8:9)])
dd <- rbind(protected, unprotected)

ggplot(dd, aes(x = Time, y = Area, fill = Status,alpha=Time),lty="blank") +
  geom_bar(position = "stack", stat = "identity", size=1.1) +
  scale_alpha_manual("Time",values=c(1, 0.5),labels=c("Present","2050"))+
  facet_grid(~Vegetation_Type, switch = "x")+
  geom_errorbar(aes(ymin=Minimum, ymax=Maximum), size=1,
                width=.4, position=position_dodge(width=0.5), 
                color="black", alpha=1) +
  labs(x="Vegetation type",
       y=expression(paste("Area (",10^3," ",km^2,"",sep = ")")))+ 
  scale_fill_manual("Protection",
                    values=c("#c4d398","#95af44"),
                    labels=c("Not Protected","Protected"))+  #S
  #scale_fill_manual("Protection",values=c("#f1e1b0","#e8c970"),
  #labels=c("Not Protected","Protected")) + #G
  #scale_fill_manual("Protection",values=c("#f3dbdb","#ebbdbf"),l
  #abels=c("Not Protected","Protected")) + #P
  theme(legend.position = "none", axis.ticks.x = element_blank(), 
        axis.text.y = element_text(colour="black"),
        axis.text.x=element_blank(),strip.background=element_rect(fill="white"),
        panel.background = element_blank(),panel.spacing = unit(-0.5, "lines"), 
        text = element_text(size=20))+
  guides(alpha = guide_colorbar(order = 1),fill = guide_legend(order = 1))

# colours were manually changed in inkscape

################################################################################
###
### Figure 3: the red list classification

# restricted distribution:

# 5000 = vulnerable, 2000 is endangered and 200 is critically endangered
# none of then are below 5000 so all vegetation types are not threatened
# according to this classification

#decline in distribution:

#calculate for all models, how they change from now to future

now <- present[, c(3,6,7)]
names(now)[3] <- "Past_Area"

future <- merge(future, now)
future$Past_Area <- future$Past_Area*1000
future$Change_Area <- ((1-future$Area/future$Past_Area)*-1)*100 
#1-fraction remaining area *-1 = fraction of lost area

redlist <- subset(future, future$Status=="All")

#let's round and classify levels
redlist$Change_Area <- round(redlist$Change_Area, digits=2)
redlist$Red_List <- NA
redlist$Red_List <- ifelse(redlist$Change_Area > (-30), 
                           "Not threatened", 
                           redlist$Red_List)

redlist$Red_List <- ifelse(redlist$Change_Area <= (-30), 
                           "Vulnerable", 
                           redlist$Red_List)

redlist$Red_List <- ifelse(redlist$Change_Area <= (-50), 
                           "Endangered", 
                           redlist$Red_List)

redlist$Red_List <- ifelse(redlist$Change_Area <= (-80), 
                           "Critically endangered", 
                           redlist$Red_List)

#realistic: rpred_20km_e3v_585

real <-  subset(redlist, redlist$Model==sprintf("%s", real_mod))

#calc envelopes

#so we take each vegetation, minus present, and calculate which is max and min
large <- list()

veg <- unique(real$Vegetation_Type)

for (i in 1:length(veg)){
  a <- subset(redlist, redlist$Vegetation_Type==veg[i])
  
  large[[i]] <- data.frame(Vegetation_Type = veg[i],
                          Maximum = max(a$Change_Area),
                          Minimum = min(a$Change_Area))
}

envelopes <- do.call(rbind, large)
real <- merge(real, envelopes, by="Vegetation_Type")


ggplot(real, aes(x=reorder(Vegetation_Type, Change_Area), y=Change_Area)) + 
  geom_rect(aes(xmin=-Inf, xmax=Inf,ymin = -30, ymax = Inf), 
            fill="#00426B", alpha = 0.08)+
  geom_rect(aes(xmin=-Inf, xmax=Inf,ymin = -50, ymax = -30), 
            fill="#BA832B", alpha = 0.08)+
  geom_rect(aes(xmin=-Inf, xmax=Inf,ymin = -50, ymax = -80), 
            fill="#BA622B", alpha = 0.08)+
  geom_rect(aes(xmin=-Inf, xmax=Inf,ymin = -80, ymax = -100), 
            fill="#681300", alpha = 0.08)+
  geom_linerange(aes(ymin = Minimum, ymax = Maximum))+
  geom_point(aes(col = factor(Red_List)), size=5) +
  geom_point(shape = 1,size = 5,colour = "black")+
  labs(x= "Vegetation type", y="Change in total distribution (%)") +
  scale_color_manual("Risk status", 
                     values=c("#681300","#BA622B","#00426B" ,"#BA832B"))+
  theme_bw() +
  geom_hline(yintercept=0) + 
  theme(legend.position = c(0.11, 0.91), 
        legend.background = element_rect(fill="transparent"), 
        axis.title=element_text(size=20), 
        axis.text=element_text(size=18),
        legend.text=element_text(size=18),
        panel.grid.major.x = element_blank(),
        #panel.grid.major.y = element_blank(),
        #panel.grid.minor.y = element_blank(),
        legend.title=element_text(size=18)) +
  scale_x_discrete(limits=c("G1","P1","G2","P2","G3","S1", "G4", "S2"))+
  scale_y_continuous(breaks=c(-100,-50,0,50,80))

################################################################################
###
### Figure 4: refugia map was built in ArcMap
