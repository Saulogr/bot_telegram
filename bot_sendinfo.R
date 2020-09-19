# Importando os pacotes 
library(tidyverse)
library(telegram)
library(lubridate)

# Configrando o BOT
bot = TGBot$new(token = '1373216588:AAESixBPt6Pz1duaWgztF3lKgL2BCkS0l_c' )

# Verificando as informações do Bot
bot$getMe()

#Pegando os uptades
atlz = bot$getUpdates()
# Salvando as informações neessárias no data frame
df_info = data.frame(atlz[[2]][3][,1], atlz[[2]][4], atlz[[2]][5] )[, c(-4)]

df_info$date = as_datetime(df_info$date, tz = "America/Maceio")
