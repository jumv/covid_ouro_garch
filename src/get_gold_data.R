

library(tidyverse)
library(tidyquant)
library(purrr)



# pegando dados do ouro
gold_prices <- tq_get('GC=F',from = '2020-01-01',to = '2021-12-01')

# Colocando no disco
write.csv(gold_prices,'data/gold.csv')










