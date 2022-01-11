

# Funcao que calcula a media de interesse dos dados diarios
get_mean_daily_data <- function(daily_trends){
  mean_daily <- daily_trends %>% pull(hits) %>% mean
  daily_trends$mean_hits <- mean_daily
  daily_trends
}


# Funcao que ira recolher os dados diarios de acordo com o intervalo
get_daily_data <- function(start,end,word,state){
  # Pegando os dados
  daily_trends <- gtrends(keyword = word,
          time = paste(start,end,sep = ' '),
          geo = state,
          onlyInterest=TRUE)[[1]]
  # Fazendo tratamento de string para numeric
  daily_trends$hits <- daily_trends$hits %>% as.numeric() %>% replace_na(0)
  get_mean_daily_data(daily_trends)
}

# Iterando sobre as datas
#df_daily_trends <- map2_dfr(dates[1:5],lead(dates)[1:5],get_daily_data,'seguro desemprego')


# Normalizando e equalizando a serie
get_norm_weighted_serie <- function(df_daily_trends,mean_weekly){
  # Adicionando media da serie weekly
  df_daily_trends$mean_weekly <- mean_weekly
  # Fazendo Calculo com pesos
  df_daily_trends <- df_daily_trends %>% mutate(weighted_series = (mean_weekly/mean_hits) * hits)
  # Normalizando a serie
  df_daily_trends <- df_daily_trends %>% mutate(norm_weighted_series = (weighted_series/max(weighted_series))*100)
  df_daily_trends
}

get_trend_norm_weighted <- function(word,dates,places){
  # Gerando pesquisa de palavras semanais
  df_week_trends <- gtrends(keyword = word,
                            geo = places,
                            time = paste(dates[1],dates[length(dates)],sep = ' '),
                            onlyInterest=TRUE)[[1]]
  mean_weekly <- df_week_trends %>% pull(hits) %>% as.numeric() %>% replace_na(0) %>% mean
  # Iterando sobre as datas
  df_daily_trends <- map2_dfr(dates[1:(length(dates) -1)],lead(dates)[1:(length(dates) -1)],
                              get_daily_data,word,places)
  # Normalizando e equalizando a serie
  get_norm_weighted_serie(df_daily_trends,mean_weekly)
}

# Funcao de combinacao de palavras
get_combinations_words <- function(df_words){
  words <- combinations(dim(df_words)[1],2,df_words$words)
  words %>% as_tibble() %>% unite('words',V1:V2,sep = ' and ') %>% pull(words)
}

# Colocando trycat na iteraçao
safe_get_trend_norm_weighted <- safely(get_trend_norm_weighted)

# Gerando as combinaçoes
get_combinations <- function(state,dates,words){
  results <- words %>%
    map(safe_get_trend_norm_weighted,dates,state) 
  map(results,'result') %>% map_dfr(~{if(!is.null(.x)){.x}})
}


write_in_disk <- function(df,path = 'data/trends_normalized.csv'){
  df %>%
    select(date,keyword,geo,norm_weighted_series) %>%
    write.csv(path) 
}




