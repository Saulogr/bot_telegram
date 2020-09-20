# Importando os pacotes 
library(tidyverse)
library(telegram)
library(lubridate)
library(jpeg)
library(RODBC)
library(openxlsx )

# Conectando ao banco de dados
con = odbcConnect("conexaoraclerstudio", uid = "hr", pwd =  "hr")
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
    
        # Chave de aprovação
    # Salvando as informações necessárias no data frame
    df_info = data.frame(id_update = atlz$update_id, user = atlz[[2]][3][,1], atlz[[2]][4], atlz[[2]][5] )[, c(-4)]
    df_info$date = as_datetime(df_info$date, tz = "America/Maceio")
    df_info$text = coalesce(df_info$text,"Olá" )
    mensagem = df_info %>% filter(id_update == ultimo_update +1) %>%
      select(text)  %>% as.character() 
    
    chatid = df_info %>% filter(id_update == ultimo_update +1) %>%
      select(user.id) %>% as.integer()
    username = df_info %>% filter(id_update == ultimo_update +1) %>%
      select(user.first_name) %>% as.character()
    print(paste(username, " fez uma solicitação"))
    
    if (mensagem == "Olá" || mensagem == "/start"){
      
      msg = paste("Olá, ", username  ,
                  "Digite o número da opção que deseja:
  *1*. Número de funcionários ativos
  *2*. Salário médio
  *3*. Cargos e salários
  *4*. Salário médio por cargo")
      
      bot$set_default_chat_id(chatid)
      bot$sendMessage(msg, parse_mode = 'markdown' )
      
      # Primera mensagem
      primeira_resposta = FALSE
      LimitGet = 0
      while (primeira_resposta == FALSE && LimitGet <= 50) {
        
        atualiza_chat = bot$getUpdates(ultimo_update -5)
        LimitGet = LimitGet + 1
        df_info_chat = data.frame(id_update = atualiza_chat$update_id, user = atualiza_chat[[2]][3][,1], atualiza_chat[[2]][4], atualiza_chat[[2]][5] )[, c(-4)]
        mensagem_chat = df_info_chat %>% filter(id_update == max(df_info_chat$id_update), user.id == chatid) %>%
          select(text) %>% as.character()
        
        if (mensagem_chat == '1')
        { 
          nr_funcionarios = sqlQuery(con, "SELECT count(emp.employee_id ) total_funcionarios FROM hr.employees emp")
          nr_funcionarios = as.character(nr_funcionarios[1,1])
          bot$sendMessage(paste("O número de funcionários ativos é de : ","*", nr_funcionarios, "*"), parse_mode = 'markdown')
          primeira_resposta = TRUE 
        }
        else if (mensagem_chat == '2')
        {
          media_salarial = sqlQuery(con, "SELECT 'R$ ' || round(avg(emp.salary), 2) media FROM hr.employees emp")
          media_salarial = as.character(media_salarial[1,1])
          bot$sendMessage(paste("A Média salarial dos funcionários é de : ","*", media_salarial, "*"), parse_mode = 'markdown')
          primeira_resposta = TRUE 
          
        }
        else if (mensagem_chat == '3')
        {
          cargos = sqlQuery(con, "select JOB_TITLE, MIN_SALARY, MAX_SALARY from jobs")
          write.xlsx(cargos, "cargos_salarios.xlsx")
          bot$sendDocument("cargos_salarios.xlsx")
          unlink("cargos_salarios.xlsx")
          primeira_resposta = TRUE
        }
        else if (mensagem_chat == '4'){
          salario_medio = sqlQuery(con, "select JOB_ID, avg(salary) salario_medio  from employees group by JOB_ID")
          
          grafico = ggplot(salario_medio, aes(x = reorder(JOB_ID, SALARIO_MEDIO), y = SALARIO_MEDIO)) +
            geom_col(fill = 'royalblue') +
            labs(x = "Cargo", y = "Salário Médio R$", title = "Salário médio por cargo",
                 subtitle = "Tamando como base o último ano")+
            theme(axis.text.x = element_blank(),
                  panel.grid = element_blank() )+
            geom_label(label = salario_medio$SALARIO_MEDIO )+
            coord_flip()
          ggsave("salario_medio.png", grafico, device =  "png", width = 15, height = 20, units = "cm")
                    bot$sendPhoto("salario_medio.png", caption = "Salário médio por cargo (R$)" )
          unlink("salario_medio.png")
          primeira_resposta = TRUE
        }
        else if (LimitGet == 50){bot$sendMessage("Tempo de espera atingido. Digite *Olá* para reiniciá-lo.", parse_mode = 'markdown')
          primeira_resposta = TRUE}
        
      }
      
      
      
    } else {
      bot$set_default_chat_id(chatid)
      bot$sendMessage("Procedimento finalizado. Digite *Olá* para um novo atendimento", parse_mode = 'markdown')
      
    }
    
    # Salvando em um arquivo auxiliar
    write.csv(atual_update, "lastupdate.tlb" )
  }
  
}


