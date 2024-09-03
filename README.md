# `pathwimp`: Analysis of Path-Specific Effects Using an Imputation-Based Weighting Estimator

`pathwimp` estimates path-specific effects using an imputation-based weighting estimator.

## Syntax

```stata
pathimp depvar [if] [in], dvar(varname) d(real) dstar(real) yreg(string) [options]
```

### Parameters

- `depvar`: Specifies the outcome variable.
- `dvar(varname)`: Specifies the treatment variable, which must be binary and coded 0/1.
- `d(real)`: Specifies the reference level of treatment.
- `dstar(real)`: Specifies the alternative level of treatment, defining the treatment contrast.
- `yreg(string)`: Specifies the type of model for the outcome (options: `regress`, `logit`).

### Options

- `cvars(varlist)`: List of baseline covariates. Categorical variables must be dummy coded.
- `nointeraction`: If specified, no treatment-mediator interaction is included in the appropriate outcome model.
- `cxd`: Includes two-way interactions between treatment and baseline covariates in the outcome models.
- `cxm`: Includes two-way interactions between mediators and baseline covariates in the appropriate outcome model.
- `censor`: Specifies that the inverse probability weights are censored at their 1st and 99th percentiles.
- `sampwts(varname)`: Specifies a variable containing sampling weights to include in the analysis.

- `reps(integer)`: Number of bootstrap replications, default is 200.
- `strata(varname)`: A variable that identifies resampling strata.
- `cluster(varname)`: A variable that identifies resampling clusters.
- `level(cilevel)`: Specifies the confidence level for CIs, default is 95%.
- `seed(passthru)`: set seed for bootstrap resampling.
- `detail`: prints the fitted models for the exposure and outcome, and saves the inverse probability weights.

## Description

`pathwimp` implements a detailed procedure for analyzing path-specific effects through:

1. **Model Fitting**:
   - Fit a baseline outcome model conditional on exposure and confounders.
   - Use this model to impute potential outcomes by manipulating the treatment variable (`dvar`).

2. **Weight Calculation**:
   - Develop a logit model for the binary treatment based on confounders to create inverse probability weights.

3. **Cross-World Imputation**:
   - For each mediator in the hypothesized causal sequence:
     - Fit an outcome model conditional on the mediator(s) and other covariates.
     - Predict outcomes with adjusted treatment levels to estimate cross-world potential outcomes using calculated weights.

4. **Effect Estimation**:
   - Calculate path-specific effects using the imputed values from the models.

## Path-Specific Effects

Provides estimates for:
- Total effect
- Direct effect not mediated by any specific mediator
- Separate effects mediated by each ordered mediator

## Examples

```stata
. use nlsy79.dta
. pathwimp std_cesd_age40 ever_unemp_age3539 log_faminc_adj_age3539, dvar(att22) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) yreg(regress) reps(1000)
```

## Saved Results

`pathwimp` outputs results in `e()`, storing matrices of the total and specific path effect estimates.

## Author

**Geoffrey T. Wodtke**  
Department of Sociology, University of Chicago  
Email: [wodtke@uchicago.edu](mailto:wodtke@uchicago.edu)

## References

Wodtke, GT and Zhou, X. *Causal Mediation Analysis.* In preparation.

## See Also

- [manhelp regress](#)
- [manhelp logit](#)
- [manhelp bootstrap](#)
