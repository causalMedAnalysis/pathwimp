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
- `strata(varname)`: Variable that identifies resampling strata.
- `cluster(varname)`: Variable that identifies resampling clusters.
- `level(cilevel)`: Confidence level for constructing bootstrap confidence intervals, default is 95%.
- `seed(passthru)`: Seed for bootstrap resampling.
- `detail`: Prints the fitted models for the outcome.

## Description

`pathwimp` estimates path-specific effects using an imputation-based weighting estimator, addressing the explanatory role of multiple, causally ordered mediators.

With `K` causally ordered mediators, the implementation proceeds as follows:

1. **Fit a Baseline Model for the Outcome:**
   - Fit a model for the mean of the outcome conditional on the exposure and baseline confounders.

2. **Impute Conventional Potential Outcomes:**
   - Set `dvar = dstar` for all sample members.
   - Compute predicted values using the model from Step 1.
   - Compute the sample average of these predictions.
   - Similarly, estimate the mean of the potential outcomes under exposure `d` by setting `dvar = d` for all sample members, then compute predicted values and their sample average.

3. **Fit a Logit Model for the Exposure:**
   - Fit a logit model for the exposure conditional on the baseline confounders.
   - Use this model to compute inverse probability weights
     
4. **Impute Cross-World Potential Outcomes:**
   - For each mediator `k = 1, 2, ..., K`:
     - **(a)** Fit a model for the mean of the outcome conditional on the exposure, baseline confounders, and the mediators `Mk = {M1, ..., Mk}`.
     - **(b)** With the model from Step 4(a), set `dvar = d` for all sample members and compute a set of predicted values.
     - **(c)** Use the predicted values from step 4(b) to impute the mean of cross-world potential outcomes 
by computing the weighted mean of these predictions -- with the weights computed in step 3 -- among sample
members for whom dvar = dstar.

5. **Calculate Path-Specific Effects:**
   - Use the imputed outcomes from Steps 2 and 4 to calculate estimates for the path-specific effects.

`pathwimp` provides estimates for the total effect and K+1 path-specific effects:
- The direct effect of the exposure on the outcome that does not operate through any of the mediators.
- Separate path-specific effects operating through each of the `K` mediators, net of the mediators that precede them in causal order.

If only a single mediator is specified, `pathwimp` reverts to estimates of conventional natural direct and indirect effects through a univariate mediator.

## Examples

```stata
// Load data
use nlsy79.dta

// Default settings with two causally ordered mediators
pathwimp std_cesd_age40, dvar(att22) mvars(ever_unemp_age3539 log_faminc_adj_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) yreg(regress) reps(1000)

// Include all two-way interactions
pathwimp std_cesd_age40, dvar(att22) mvars(ever_unemp_age3539 log_faminc_adj_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) yreg(regress) cxd cxm reps(1000)

// No interactions, printing models
pathwimp std_cesd_age40, dvar(att22) mvars(ever_unemp_age3539 log_faminc_adj_age3539) cvars(female black hispan paredu parprof parinc_prank famsize afqt3) d(1) dstar(0) yreg(regress) nointer reps(1000) detail
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
