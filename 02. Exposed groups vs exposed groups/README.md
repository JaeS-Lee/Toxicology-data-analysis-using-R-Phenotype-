# Comparison between exposed groups - exposed groups

This code focuses on analyzing phenotype data between exposed - exposed groups.

Heatmaps were applied for visualization of the phenotype dataset.

Due to the dataset's property, in detail cells with less frequency than 5 is more than 20% of the total cells, we cannot use chi-squared test because this is the precondition of the analysis. 
Instead, we use Fisher's exact test using [RVAideMemoire R package](https://cran.r-project.org/web/packages/RVAideMemoire/index.html).

