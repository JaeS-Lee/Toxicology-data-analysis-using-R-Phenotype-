library(tidyverse)
library(RVAideMemoire)
library(readxl)


### Edema data preprocessing ###

edema <- readxl::read_excel("./Raw data example (Phenotype).xlsx")
edema <- edema %>% dplyr::rename(score_0 = `0`, score_1 = `1`, score_2 = `2`)
edema <- as.data.frame(edema)
edema

edema$Chemical <- gsub('_1', '', edema$Chemical)
edema$Chemical <- gsub('_2', '', edema$Chemical)
edema


edema_sum <- aggregate(. ~ Chemical, edema, sum, na.rm = F)
# Reference : https://stackoverflow.com/questions/64179482/how-to-sum-values-using-r-based-on-the-same-row-id


edema %>% dplyr::distinct(Chemical)
# Reference : https://datatofish.com/replace-values-dataframe-r/


edema_sum$Chemical[edema_sum$Chemical == 'Chemical A 1uM'] = 'A_1'
edema_sum$Chemical[edema_sum$Chemical == 'Chemical A 2uM'] = 'A_2'
edema_sum$Chemical[edema_sum$Chemical == 'Chemical A 3uM'] = 'A_3'
edema_sum$Chemical[edema_sum$Chemical == 'Chemical A 4uM'] = 'A_4'
edema_sum$Chemical[edema_sum$Chemical == 'Chemical A 5uM'] = 'A_5'

edema_sum$Chemical[edema_sum$Chemical == 'Chemical B 1uM'] = 'B_1'
edema_sum$Chemical[edema_sum$Chemical == 'Chemical B 2uM'] = 'B_2'
edema_sum$Chemical[edema_sum$Chemical == 'Chemical B 3uM'] = 'B_3'
edema_sum$Chemical[edema_sum$Chemical == 'Chemical B 4uM'] = 'B_4'
edema_sum$Chemical[edema_sum$Chemical == 'Chemical B 5uM'] = 'B_5'

chem_order_edema <- factor(edema_sum$Chemical, 
                           levels = c('Control', 'A_1', 'A_2', 'A_3', 'A_4', 'A_5',
                                      'B_1', 'B_2', 'B_3', 'B_4', 'B_5'))

edema_sum <- edema_sum %>% arrange(chem_order_edema)
edema_sum


### Divide them into two groups : Chemical A and B

edema_sum_A <- edema_sum[c(1,2,3,4,5,6), ]
edema_sum_A


edema_sum_B <- edema_sum[c(1,7,8,9,10,11), ]
edema_sum_B


### Chem names as rownames of each chemical groups

rownames(edema_sum_A) <- edema_sum_A$Chemical
edema_sum_A <- edema_sum_A %>% select(2,3,4,5) ## A group
edema_sum_A

rownames(edema_sum_B) <- edema_sum_B$Chemical
edema_sum_B <- edema_sum_B %>% select(2,3,4,5) ## B group
edema_sum_B

#####################################################################################################

### Visualization ###

### Graphs (A edema)

edema_sum_A_m <- as.matrix(edema_sum_A)
edema_sum_A_p <- prop.table(edema_sum_A_m, 1)
edema_sum_A_pp <- edema_sum_A_p*100
edema_sum_A_pp


mar.default <- c(5, 4, 4, 2) + 0.1
par(mar = mar.default + c(0, 5, 1, 1))
barplot((t(edema_sum_A_pp)), horiz=TRUE, las=1, beside=F, xlim=c(0, 100), 
        legend=F, col=c("white", "pink", "red", "black"))

### Graphs (B edema)

edema_sum_B_m <- as.matrix(edema_sum_B)
edema_sum_B_p <- prop.table(edema_sum_B_m, 1)
edema_sum_B_pp <- edema_sum_B_p*100
edema_sum_B_pp


mar.default <- c(5, 4, 4, 2) + 0.1
par(mar = mar.default + c(0, 5, 1, 1))
barplot((t(edema_sum_B_pp)), horiz=TRUE, las=1, beside=F, xlim=c(0, 100), 
        legend=F, col=c("white", "pink", "red", "black"))

#####################################################################################################

### Statistical analysis ###

### Statistics (A edema)

edema_sum_A_stat <- edema_sum_A %>% dplyr::mutate(score_affected = score_1 + score_2 + Dead)
edema_sum_A_stat <- edema_sum_A_stat %>% dplyr::select(score_0, score_affected)
edema_sum_A_stat <- as.matrix(edema_sum_A_stat)
edema_sum_A_stat


fisher.test(edema_sum_A_stat, workspace = 20000000, simulate.p.value = T)
fisher_posthoc_result_A_pe <- fisher.multcomp(edema_sum_A_stat, p.method = 'fdr') ## matrix format is also OK
fisher_posthoc_result_A_pe


### Statistics (B edema)

edema_sum_B_stat <- edema_sum_B %>% dplyr::mutate(score_Affected = score_1 + score_2 + Dead)
edema_sum_B_stat <- edema_sum_B_stat %>% dplyr::select(score_0, score_Affected)
edema_sum_B_stat <- as.matrix(edema_sum_B_stat)
edema_sum_B_stat


fisher.test(edema_sum_B_stat, workspace = 20000000, simulate.p.value = T)
fisher_posthoc_result_B_pe <- fisher.multcomp(edema_sum_B_stat, p.method = 'fdr') ## matrix format is also OK
fisher_posthoc_result_B_pe