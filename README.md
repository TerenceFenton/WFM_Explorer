# WFM_Explorer
Within this project, I utilize the Warframe.market v1 and v2 public API's to assess current in game market trends. 

The API's do most of the heavy lifting by calling json dataframes that already exist on the website in formats of 48 Hour and 90 Day trade volumes. To see what warframe mods are selling the most right now, all you need to do is run **syndAugStatDisplay.Rmd** (which needs **mainWFM.R** in the same folder in order to work), sitback and grab a coffee.

A current limitation is that each augment mod's json dataframe needs to be called individually from the server. To prevent overloading the server with too many calls, a half second break is implemented between each call. This leads the call to take a few minutes but it's worth it! If you view the example html file in the web you should see what it's supposed to look like.

The code should run as is, but if it doesn't for any reason then please let me know and I'll make the necessary adjustments.
