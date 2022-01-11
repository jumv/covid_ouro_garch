
library(tidyverse)


# Lendo os dados
df_gold <- read.csv('data/gold.csv')[,-1]
df_trends <- read.csv('data/trends_normalized.csv')[,-1]

# Fazendo o join
df_gold %>% inner_join(df_trends) %>% write.csv('data/gold_trends.csv')

