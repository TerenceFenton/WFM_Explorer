library(rvest)

page_html <- read_html("https://www.warframe.com/game/warframes")

htmlImages <- page_html %>% 
  html_elements("img") %>%
  html_attr("src")

iswfImage <- grepl("https://content.warframe.com/PublicExport/Lotus/Interface/Icons/StoreIcons/Warframes/",
                  htmlImages,
                  fixed = TRUE)

wfImages <- htmlImages[iswfImage]