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
  
  # Nada a fazer
} else {
  
  print("Houve mudança")

  # Salvando as informações necessárias no data frame
  df_info = data.frame(id_update = atlz$update_id, user = atlz[[2]][3][,1], atlz[[2]][4], atlz[[2]][5] )[, c(-4)]
  df_info$date = as_datetime(df_info$date, tz = "America/Maceio")
  mensagem = df_info %>% filter(id_update == ultimo_update +1) %>%
    select(text) %>% as.character()
  
  user.id = df_info %>% filter(id_update == ultimo_update +1) %>%
    select(user.id) %>% as.integer()
  username = df_info %>% filter(id_update == ultimo_update +1) %>%
    select(user.first_name) %>% as.character()
  
  if (mensagem == "Olá"){
    
    msg = paste("Olá, ", username  ,
"Qual opção você deseja?
  1. Número de ocorrências
  2. Faturamento
  3. Tempo médio de atendimento
  4. DEC
  5. FEC")
    
    bot$set_default_chat_id(user.id)
    bot$sendMessage(msg, parse_mode = 'markdown' )
  } else {
    bot$set_default_chat_id(user.id)
    bot$sendMessage("Não entendi o que você quis falar. Digite Olá para ver as iformações")
    
  }
  
  # Salvando em um arquivo auxiliar
  write.csv(atual_update, "lastupdate.tlb" )
}

}


