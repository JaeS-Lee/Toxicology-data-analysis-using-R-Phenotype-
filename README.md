# Toxicology data analysis using R (Phenotype)

In this repository, I will introduce preprocessing, statistical analysis, and visualization for zebrafish phenotype results.
In our lab, zebrafish phenotype is performed using scoring method: "0" means normal, "1" means slight malformation, and "2" means severe malformation.
We count how many embryos are score 0, 1, or 2 and make contingency table but, in general, our tables do not fulfill the precondition of using chi-square.
Thus, we normally use modified Fisher's exact test for statistical analysis.
All example data showed in this section are all modified data, not our original data.
