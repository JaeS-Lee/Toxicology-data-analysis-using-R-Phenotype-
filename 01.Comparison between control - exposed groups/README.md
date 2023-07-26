# Comparison between control - exposed groups

This code focuses on analyzing phenotype data between control - exposed groups. Due to the dataset's property, in detail cells with less frequency than 5 is more than 20% of the total cells, we cannot use chi-squared test because this is the precondition of the analysis. Instead, we use Fisher's exact test
