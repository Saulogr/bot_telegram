# Importando os pacotes 
library(tidyverse)
library(telegram)
library(lubridate)

# Configrando o BOT
bot = TGBot$new(token = '1373216588:AAESixBPt6Pz1duaWgztF3lKgL2BCkS0l_c' )

# Verificando as informações do Bot
bot$getMe()


while (TRUE) {
  

#Pegando os uptades
atlz = bot$getUpdates()

# Coletando o número do último update e realizando o teste para saber se houve mudanças
ultimo_update =  read.csv("lastupdate.tlb")[1,2]
atual_update = max(atlz$update_id)

if (ultimo_update == atual_update){
  
  print("Não houve mudança")
} else {
  
  print("Houve mudança")
  write.csv(atual_update, "lastupdate.tlb" )
}

}

# Salvando em um arquivo auxiliar

# Salvando as informações neessárias no data frame
df_info = data.frame(atlz[[2]][3][,1], atlz[[2]][4], atlz[[2]][5] )[, c(-4)]
# Mudando o formato da data
df_info$date = as_datetime(df_info$date, tz = "America/Maceio")
