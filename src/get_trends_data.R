

# pacotes
library(gtrendsR)
library(gtools)
library(dplyr)
library(tidyr)
library(purrr)
library(lubridate)
source('src/utils.R')

# Pegando palavras
words <- read.csv('data/words.csv')$words


# Gerando datas intervaladas de 9 em 9 meses
dates <- c('2020-01-01','2020-08-01','2021-04-01','2021-12-01')

# Colocando estados
states <- c('US-ME','US-VT','US-NH','US-MA','US-RI','US-CT','US-NY','US-PA','US-NJ','US-DE',
            'US-DE','US-MD','US-DC','US-OH','US-MI','US-WV','US-NC','US-SC','US-GA','US-FL')


# Gerando dados
df <- states %>% map_dfr(get_combinations,dates,words)

# Salvando no disco
write_in_disk(df)

