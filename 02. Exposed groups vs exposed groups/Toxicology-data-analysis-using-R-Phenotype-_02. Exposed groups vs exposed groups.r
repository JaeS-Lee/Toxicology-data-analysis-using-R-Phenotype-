library(tidyverse)
library(reshape2)
library(RVAideMemoire)
library(readxl)

#### ED : Edema ####

# Reference : https://stackoverflow.com/questions/51930684/read-excel-file-and-select-specific-rows-and-columns

ed <- readxl::read_excel("./Raw data example (Phenotype 2).xlsx")
ed <- ed %>% dplyr::rename(score_0 = `0`, score_1 = `1`, score_2 = `2`)
ed <- as.data.frame(ed)

ed$Chemical <- gsub('_1', '', ed$Chemical)
ed$Chemical <- gsub('_2', '', ed$Chemical)
ed$Chemical <- gsub('_3', '', ed$Chemical)

# Reference : https://stackoverflow.com/questions/64179482/how-to-sum-values-using-r-based-on-the-same-row-id

ed_sum <- aggregate(. ~ Chemical, ed, sum, na.rm = F)


# Reference : https://datatofish.com/replace-values-dataframe-r/

ed_sum$Chemical[ed_sum$Chemical == 'Chemical A 0.1uM'] = 'A_0.1'
ed_sum$Chemical[ed_sum$Chemical == 'Chemical A 1uM'] = 'A_1'
ed_sum$Chemical[ed_sum$Chemical == 'Chemical B 1uM'] = 'B_1'
ed_sum$Chemical[ed_sum$Chemical == 'Chemical B 2uM'] = 'B_2'
ed_sum$Chemical[ed_sum$Chemical == 'Chemical A 1uM + Chemical B 1 uM'] = 'A_1_B_1'
ed_sum$Chemical[ed_sum$Chemical == 'Chemical A 1uM + Chemical B 2 uM'] = 'A_1_B_2'


chem_order <- factor(ed_sum$Chemical, levels = c('Control', 'A_0.1', 'A_1', 'B_1', 'B_2',
                                                 'A_1_B_1', 'A_1_B_2'))

ed_sum <- ed_sum %>% arrange(chem_order)
ed_sum

rownames(ed_sum) <- ed_sum$Chemical
ed_sum <- ed_sum %>% select(2,3,4,5)

ed_sum_matrix <- as.matrix(ed_sum)
ed_sum_matrix


### Boxplot visualization

edema_sum_m <- as.matrix(ed_sum_matrix)
edema_sum_p <- prop.table(edema_sum_m, 1)
edema_sum_pp <- edema_sum_p*100
edema_sum_pp

mar.default <- c(5, 4, 4, 2) + 0.1
par(mar = mar.default + c(0, 5, 1, 1))
barplot((t(edema_sum_pp)), horiz=TRUE, las=1, beside=F, xlim=c(0, 100), 
        legend=F, col=c("white", "pink", "red", "black"))



### Make matrix for analysis

fisher.test(ed_sum_matrix, workspace = 200000000, simulate.p.value = T)
fisher_posthoc_result_ed <- fisher.multcomp(ed_sum_matrix, p.method = 'fdr') ## matrix format is also OK
fisher_posthoc_result_ed

# In the r x c case with r > 2 or c > 2, internal tables can get too large for the exact test in which 
# case an error is signalled. Apart from increasing workspace sufficiently, which then may lead to very long running times, 
# using simulate.p.value = TRUE may then often be sufficient and hence advisable.

fisher_posthoc_result_ed_df <- fisher_posthoc_result_ed$p.value

fisher_posthoc_result_ed_df_melt <- melt(fisher_posthoc_result_ed_df)
head(fisher_posthoc_result_ed_df_melt)


### Fisher's exact test visualization

ghm_ed <- ggplot(fisher_posthoc_result_ed_df_melt, aes(x = Var1, y = Var2, fill = value))
ghm_ed <- ghm_ed + geom_tile()
ghm_ed <- ghm_ed + theme_bw()
ghm_ed <- ghm_ed + theme(plot.background = element_blank(),
                         panel.grid.minor = element_blank(),
                         panel.grid.major = element_blank(),
                         panel.background = element_blank(),
                         axis.line = element_blank(),
                         axis.ticks = element_blank(),
                         strip.background = element_rect(fill = "white", colour = "white"),
                         axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1))

ghm_ed <- ghm_ed + scale_fill_gradientn(colors = c("forestgreen", "forestgreen", 'gray', 'gray'), 
                                        limits = c(0, 1), 
                                        breaks = c(0, 0.05, 1),
                                        values = c(0, 0.04999, 0.05, 1),
                                        guide = 'colourbar',
                                        name = 'P-value')

ghm_ed <- ghm_ed + xlab("Chemical combination") + ylab("Score combination") + ggtitle("BisMP ED")
ghm_ed

# Reference : https://stats.biopapyrus.jp/r/ggplot/geom-tile.html
# Reference : https://stackoverflow.com/questions/43838929/r-ggplot2-adjust-distance-between-breaks-on-a-continuous-colourbar-gradient
# Reference : https://biolab.sakura.ne.jp/fisher-multcomp.html