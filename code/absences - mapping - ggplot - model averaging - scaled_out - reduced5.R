# http://uchicagoconsulting.wordpress.com/tag/r-ggplot2-maps-visualization/

load("C:/Users/Mike/Desktop/Dropbox/absences/workspace - avg glm - scaled_out - reduced5 - opt_threshold.RData")

library(MuMIn)
library(ggplot2)
library(maps)
library(maptools) # import for gcDestination
library(grid)
library(gridExtra)
library(mapproj)
library(scales)

#load us map data
all_states <- map_data("state")

# subset the states you want to see 
states <- subset(all_states, region %in% c("connecticut"))

#####################
# A blank map of CT #
#####################
p <- ggplot()
p <- p + geom_polygon(data=states, aes(x=long, y=lat, group = group),colour="black", fill="white" )
p <- p + theme_classic()
p

# need to fix dataSPACE. The longitude should be negative 
# dataSPACE$longitude <- dataSPACE$longitude*-1

########################
# prepare a data frame #
########################
# these are the columns that I want from "data" data frame 
data$waterbody 
data$latitude 
data$longitude 
data$lemna_minor
data$spirodela_polyrhiza
data$wolffia_sp
data$FP_presence
data$FP_species_richness

# these are the predicted values from the best glms
predict(avg_LM_scaled_out_reduc, temp_data_LM, type="response")
predict(avg_SP_scaled_out_reduc, temp_data_SP, type="response")
predict(avg_W_scaled_out_reduc, temp_data_W, type="response")
predict(avg_FPrich_scaled_out_reduc, temp_data_FPrich, type="response")
predict(avg_FPpres_scaled_out_reduc, temp_data_FPpres, type="response")

data_glm_map <- cbind(data$waterbody[-129], 
                  data$latitude[-129], 
                  data$longitude[-129], 
                  data$lemna_minor[-129],
                  data$spirodela_polyrhiza[-129],
                  data$wolffia_sp[-129],
                  data$FP_presence[-129],
                  data$FP_species_richness[-129],
                  predict(avg_LM_scaled_out_reduc, temp_data_LM, type="response"),
                  predict(avg_SP_scaled_out_reduc, temp_data_SP, type="response"),
                  predict(avg_W_scaled_out_reduc, temp_data_W, type="response"),
                  predict(avg_FPrich_scaled_out_reduc, temp_data_FPrich, type="response"),
                  predict(avg_FPpres_scaled_out_reduc, temp_data_FPpres, type="response")
                  )
 
colnames(data_glm_map) <- c("waterbody","lat","lon","LM_obsv","SP_obsv","W_obsv",
                            "FPpres_obsv","FPrich_obsv","LM_pred","SP_pred","W_pred",
                            "FPrich_pred","FPpres_pred")

data_glm_map <- as.data.frame(data_glm_map)

###########################
# A map of surveyed lakes #
###########################
p <- ggplot()
p <- p + geom_polygon(data=states, aes(x=long, y=lat, group = group),colour="white" )
p <- p + geom_point( data=data_glm_map, aes(x=lon, y=lat), color="coral1") 
p <- p + theme_classic()
p

####################### 
# Set up color scales # 
#######################
cols <- rev(brewer_pal(pal = "RdBu")(5))

##############################################
# combined figure with maps of LM, SP, and W #
##############################################
map_LM_glm2 <- ggplot()
map_LM_glm2 <- map_LM_glm2 + geom_polygon(data=states, aes(x=long, y=lat, group = group),colour="black",fill="grey85")
map_LM_glm2 <- map_LM_glm2 + coord_map()
map_LM_glm2 <- map_LM_glm2 + geom_point(data=data_glm_map, aes(x=lon, y=lat, shape=as.factor(LM_obsv)),colour="black",size=5.5) 
map_LM_glm2 <- map_LM_glm2 + geom_point(data=data_glm_map, aes(x=lon, y=lat, colour=LM_pred, shape=as.factor(LM_obsv)),size=4) 
map_LM_glm2 <- map_LM_glm2 + scale_colour_gradientn(colours=cols,
                                                    name="Predicted",
                                                    values=rescale(c(0,LM_threh/2,LM_threh,LM_threh*3/2,max(data_glm_map$LM_pred))),
                                                    guide="colorbar",
                                                    limits=c(0,1)
                                                    )
map_LM_glm2 <- map_LM_glm2 + scale_shape_discrete(name="Observed",labels=c("absent","present"))
map_LM_glm2 <- map_LM_glm2 + theme_classic(base_size=18)
map_LM_glm2 <- map_LM_glm2 + theme(line = element_blank(),             # get rid of axes 
                                 axis.text.x = element_blank(),
                                 axis.text.y = element_blank(), 
                                 axis.ticks.x = element_blank(),
                                 axis.ticks.y = element_blank(), 
                                 axis.title = element_blank(),
                                 rect = element_blank()
                            )
map_LM_glm2

map_SP_glm2 <- ggplot()
map_SP_glm2 <- map_SP_glm2 + geom_polygon(data=states, aes(x=long, y=lat, group = group),colour="black",fill="grey85")
map_SP_glm2 <- map_SP_glm2 + coord_map()
map_SP_glm2 <- map_SP_glm2 + geom_point(data=data_glm_map, aes(x=lon, y=lat, shape=as.factor(SP_obsv)),colour="black",size=5.5) 
map_SP_glm2 <- map_SP_glm2 + geom_point(data=data_glm_map, aes(x=lon, y=lat, colour=SP_pred, shape=as.factor(SP_obsv)), size=4) 
map_SP_glm2 <- map_SP_glm2 + scale_colour_gradientn(colours=cols,
                                                  name="Predicted",
                                                  values=rescale(c(0,SP_threh/2,SP_threh,SP_threh*3/2,max(data_glm_map$SP_pred))),
                                                  guide="colorbar",
                                                  limits=c(0,max(data_glm_map$SP_pred))
                  )
map_SP_glm2 <- map_SP_glm2 + scale_shape_discrete(name="Observed",labels=c("absent","present"))
map_SP_glm2 <- map_SP_glm2 + theme_classic(base_size=18)
map_SP_glm2 <- map_SP_glm2 + theme(line = element_blank(),             # get rid of axes 
                                 axis.text.x = element_blank(),
                                 axis.text.y = element_blank(), 
                                 axis.ticks.x = element_blank(),
                                 axis.ticks.y = element_blank(), 
                                 axis.title = element_blank(),
                                 rect = element_blank()
)
map_SP_glm2

map_W_glm2 <- ggplot()
map_W_glm2 <- map_W_glm2 + geom_polygon(data=states, aes(x=long, y=lat, group = group),colour="black",fill="grey85")
map_W_glm2 <- map_W_glm2 + coord_map()
map_W_glm2 <- map_W_glm2 + geom_point(data=data_glm_map, aes(x=lon, y=lat, shape=as.factor(W_obsv)),colour="black",size=5.5) 
map_W_glm2 <- map_W_glm2 + geom_point(data=data_glm_map, aes(x=lon, y=lat, colour=W_pred, shape=as.factor(W_obsv)), size=4) 
map_W_glm2 <- map_W_glm2 + scale_colour_gradientn(colours=cols,
                                                    name="Predicted",
                                                    values=rescale(c(0,W_threh/2,W_threh,W_threh*3/2,max(data_glm_map$W_pred))),
                                                    guide="colorbar",
                                                    limits=c(0,max(data_glm_map$W_pred))
)
map_W_glm2 <- map_W_glm2 + scale_shape_discrete(name="Observed",labels=c("absent","present"))
map_W_glm2 <- map_W_glm2 + theme_classic(base_size=18)
map_W_glm2 <- map_W_glm2 + theme(line = element_blank(),             # get rid of axes 
                               axis.text.x = element_blank(),
                               axis.text.y = element_blank(), 
                               axis.ticks.x = element_blank(),
                               axis.ticks.y = element_blank(), 
                               axis.title = element_blank(),
                               rect = element_blank()
)
map_W_glm2



map_FPpres_glm2 <- ggplot()
map_FPpres_glm2 <- map_FPpres_glm2 + geom_polygon(data=states, aes(x=long, y=lat, group = group),colour="black",fill="grey85")
map_FPpres_glm2 <- map_FPpres_glm2 + coord_map()
map_FPpres_glm2 <- map_FPpres_glm2 + geom_point(data=data_glm_map, aes(x=lon, y=lat, shape=as.factor(FPpres_obsv)),colour="black",size=5.5) 
map_FPpres_glm2 <- map_FPpres_glm2 + geom_point(data=data_glm_map, aes(x=lon, y=lat, colour=FPpres_pred, shape=as.factor(FPpres_obsv)), size=4) 
map_FPpres_glm2 <- map_FPpres_glm2 + scale_colour_gradientn(colours=cols,
                                                  name="Predicted",
                                                  values=rescale(c(0,FPpres_threh/2,FPpres_threh,FPpres_threh*3/2,max(data_glm_map$FPpres_pred))),
                                                  guide="colorbar",
                                                  limits=c(0,max(data_glm_map$FPpres_pred))
)
map_FPpres_glm2 <- map_FPpres_glm2 + scale_shape_discrete(name="Observed",labels=c("absent","present"))
map_FPpres_glm2 <- map_FPpres_glm2 + theme_classic(base_size=18)
map_FPpres_glm2 <- map_FPpres_glm2 + scaleBar(lon = -72.5, lat = 41.,          # add a scale bar
                                    distanceLon = 25, 
                                    distanceLat = 4, distanceLegend = 9, 
                                    dist.unit = "km", orientation = FALSE,
                                    legend.size = 6)
map_FPpres_glm2 <- map_FPpres_glm2 + theme(line = element_blank(),             # get rid of axes 
                                 axis.text.x = element_blank(),
                                 axis.text.y = element_blank(), 
                                 axis.ticks.x = element_blank(),
                                 axis.ticks.y = element_blank(), 
                                 axis.title = element_blank(),
                                 rect = element_blank()
)
map_FPpres_glm2



map_all_species_glm <- arrangeGrob(map_LM_glm2,map_SP_glm2,map_W_glm2,map_FPpres_glm2)
map_all_species_glm

ggsave("map_all_species_glm_scaled_out_reduc5.jpg",map_all_species_glm,height=12,width=24)

# THIS STILL NEEDS TO BE MODIFIED & ANNOTATED
# ADD a) b) c) d)
# remove extra legends 

################################################################
# A map of FPrich glm # alternative plotting for pred vs. obsv # Alt. with black lines around the points !
################################################################

map_FPrich_glm <- ggplot()
map_FPrich_glm <- map_FPrich_glm + geom_polygon(data=states, aes(x=long, y=lat, group = group),colour="black",fill="grey85")
map_FPrich_glm <- map_FPrich_glm + coord_map()
map_FPrich_glm <- map_FPrich_glm + geom_point(data=data_glm_map, aes(x=lon, y=lat, fill=FPrich_obsv), colour="black", pch=21, size=5.5) 
map_FPrich_glm <- map_FPrich_glm + geom_point(data=data_glm_map, aes(x=lon, y=lat, fill=FPrich_pred), colour="black", pch=21, size=3.5) 
map_FPrich_glm <- map_FPrich_glm + scale_fill_gradientn("Richness",colours=c("navyblue","white","red"))
map_FPrich_glm <- map_FPrich_glm + theme_classic(base_size=18)
map_FPrich_glm <- map_FPrich_glm + scaleBar(lon = -72.5, lat = 41.,          # add a scale bar
                                            distanceLon = 25, 
                                            distanceLat = 4, distanceLegend = 9, 
                                            dist.unit = "km", orientation = FALSE,
                                            legend.size = 6)
map_FPrich_glm <- map_FPrich_glm + theme(line = element_blank(),             # get rid of axes 
                                         axis.text.x = element_blank(),
                                         axis.text.y = element_blank(), 
                                         axis.ticks.x = element_blank(),
                                         axis.ticks.y = element_blank(), 
                                         axis.title = element_blank(),
                                         rect = element_blank()
)
map_FPrich_glm
ggsave("map_FPrich_glm_model_avg_scaled_out_reduc5.jpg",map_FPrich_glm,height=8,width=11)

########
# Save #
########
