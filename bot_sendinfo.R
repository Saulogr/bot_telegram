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
  ultimo_update =  read.csv("lastupdate.tlb")[1,2]
atlz = bot$getUpdates(ultimo_update -5)

# Coletando o número do último update e realizando o teste para saber se houve mudanças
ultimo_update =  read.csv("lastupdate.tlb")[1,2]
atual_update = max(atlz$update_id)

if (atual_update == ultimo_update){
  
  # Nada a fazer
} else {
  
  print("Houve mudança")
  # Chave de aprovação
    # Salvando as informações necessárias no data frame
  df_info = data.frame(id_update = atlz$update_id, user = atlz[[2]][3][,1], atlz[[2]][4], atlz[[2]][5] )[, c(-4)]
  df_info$date = as_datetime(df_info$date, tz = "America/Maceio")
  mensagem = df_info %>% filter(id_update == ultimo_update +1) %>%
    select(text) %>% as.character()
  
  chatid = df_info %>% filter(id_update == ultimo_update +1) %>%
    select(user.id) %>% as.integer()
  username = df_info %>% filter(id_update == ultimo_update +1) %>%
    select(user.first_name) %>% as.character()
  
  if (mensagem == "Olá"){
    
    msg = paste("Olá, ", username  ,
"Digite o número da opção que deseja:
  *1*. Número de ocorrências
  *2*. Faturamento
  *3*. Tempo médio de atendimento
  *4*. DEC
  *5*. FEC")
    
    bot$set_default_chat_id(chatid)
    bot$sendMessage(msg, parse_mode = 'markdown' )
  
  # Primera mensagem
  primeira_resposta = FALSE
  LimitGet = 0
  while (primeira_resposta == FALSE && LimitGet <= 20) {
    
    atualiza_chat = bot$getUpdates(ultimo_update -5)
    LimitGet = LimitGet + 1
    df_info_chat = data.frame(id_update = atualiza_chat$update_id, user = atualiza_chat[[2]][3][,1], atualiza_chat[[2]][4], atualiza_chat[[2]][5] )[, c(-4)]
    mensagem_chat = df_info_chat %>% filter(id_update == max(df_info_chat$id_update), user.id == chatid) %>%
      select(text) %>% as.character()
    
    if (mensagem_chat == '1')
      {bot$sendMessage("Você digitou 1", parse_mode = 'markdown' ) 
        primeira_resposta = TRUE 
    }
    else if (mensagem_chat == '2')
      {bot$sendMessage("Você digitou 2", parse_mode = 'markdown' )
        primeira_resposta = TRUE}
    else if (mensagem_chat == '3')
      {bot$sendMessage("Você digitou 3", parse_mode = 'markdown' )
        primeira_resposta = TRUE}
    else if (mensagem_chat == '4'){bot$sendMessage("Você digitou 4", parse_mode = 'markdown' )
        primeira_resposta = TRUE}
    else if (mensagem_chat == '5'){bot$sendMessage("Você digitou 5", parse_mode = 'markdown')
        primeira_resposta = TRUE}
    else if (LimitGet == 20){bot$sendMessage("Tempo de espera atingido. Digite *Olá* para reiniciá-lo.", parse_mode = 'markdown')
      primeira_resposta = TRUE}

  }
  
  
   
  } else {
    bot$set_default_chat_id(chatid)
    bot$sendMessage("Procedimento finalizado. Digite *Olá* para um novo atendimento")
    
  }
  
  # Salvando em um arquivo auxiliar
  write.csv(atual_update, "lastupdate.tlb" )
}

}


