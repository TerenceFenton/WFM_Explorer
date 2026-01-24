library(jsonlite)
library(httr)
library(progress)

# Warframe Market Plugin
url <- "https://api.warframe.market/v2/items"


# Extract items from json 
resp <- GET(
  url,
  add_headers(
    "Accept" = "application/json",
    "User-Agent" = "R warframe.market client"
  )
)


content <- content(resp, as = "text", encoding = "UTF-8")
data <- fromJSON(content)


# Grab Syndicate Augment Mods
filter1 <- grepl("/Powersuits", data$data$gameRef, fixed = TRUE)
syndAugSlug <- data$data$slug[filter1]


filter2 <- !(grepl("set", syndAugSlug, fixed = TRUE))
syndAugSlug <- syndAugSlug[filter2]




# Fetch Current Median Price for Syndicate Augment Mods at Rank 0




getCurrentMedianPrices <- function(slug) {
  moduleURL <- paste0("https://api.warframe.market/v2/orders/item/", 
                      slug)
  
  orderResp <- GET(
    moduleURL,
    add_headers(
      "Accept" = "application/json",
      "User-Agent" = "R warframe.market client"
    )
  )
  content <- content(orderResp, as = "text", encoding = "UTF-8")
  moduleData <- fromJSON(content)
  
  # Turn into dataframe and modify it
  df <- data.frame(plat = moduleData$data$platinum,
                   type = moduleData$data$type,
                   rank = moduleData$data$rank
                   )
  sellData <- df$plat[df$type == "sell" & df$rank == 0]
  factor(sellData)
}



# Fetch historic sales data



getHistoricMedianPrices <- function(slug) {
  moduleURL <- paste0("https://api.warframe.market/v1/items/", 
                      slug, "/statistics")
  
  orderResp <- GET(
    moduleURL,
    add_headers(
      "Accept" = "application/json",
      "User-Agent" = "R warframe.market client"
    )
  )
  content <- content(orderResp, as = "text", encoding = "UTF-8")
  moduleData <- fromJSON(content)
  
  # Process slugs into df
  df <- data.frame(
    name = slug, 
    total48HourVolume = sum(moduleData$payload$statistics_closed$`48hours`$volume),
    ave48HourMedianPrice = mean(moduleData$payload$statistics_closed$`48hours`$median),
    total90DayVolume = sum(moduleData$payload$statistics_closed$`90days`$volume),
    ave90DayMedianPrice = mean(moduleData$payload$statistics_closed$`90days`$median)
    )
  
  df
}





# Iterate through historic data 
# *NOTE* Each item will have to make an individual request to the live json
# file, making this process a bit of a haul. Be patient.




syndPB <- progress_bar$new(
  format = "Item: :current/:total [:bar] :percent :eta",
  total = length(syndAugSlug)
)

iterateHistoricSynd <- function(syndSlugList, PB) {
  df <- data.frame(name = as.character(),
                   tot48HourVolume = as.numeric(),
                   ave48HourMedianPrice = as.numeric(),
                   tot90DayVolume = as.numeric(),
                   ave90DayMedianPrice = as.numeric())
  
  for (i in 1:length(syndSlugList)) {
    PB$message(syndSlugList[i])
    newRowDf <- getHistoricMedianPrices(syndSlugList[i])
    df <- rbind(df, newRowDf)
    PB$tick()
    Sys.sleep(0.5)
  }
  df
}

historicAugData <- iterateHistoricSynd(syndAugSlug, syndPB)


