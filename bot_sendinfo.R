# Importando os pacotes 
library(tidyverse)
library(telegram)
library(lubridate)
library(jpeg)

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

  # Salvando as informações necessárias no data frame
  df_info = data.frame(id_update = atlz$update_id, user = atlz[[2]][3][,1], atlz[[2]][4], atlz[[2]][5] )[, c(-4)]
  df_info$date = as_datetime(df_info$date, tz = "America/Maceio")
  mensagem = df_info %>% filter(id_update == ultimo_update +1) %>%
    select(text) %>% as.character()
  
  user.id = df_info %>% filter(id_update == ultimo_update +1) %>%
    select(user.id) %>% as.integer()
  
  if (mensagem == "Olá"){
    
    img = readJPEG("CJNYCB45H4GE56DH5YB3AV7BX4.jpg" )
    
    bot$set_default_chat_id(user.id)
    bot$sendPhoto("CJNYCB45H4GE56DH5YB3AV7BX4.jpg", caption = 'Aqui tem coragem')
  }
  
  
  # Salvando em um arquivo auxiliar
  write.csv(atual_update, "lastupdate.tlb" )
}

}


