*!TITLE: PATHWIMP - path-specific effects using an imputation-based weighting estimator
*!AUTHOR: Geoffrey T. Wodtke, Department of Sociology, University of Chicago
*!
*! version 0.1 
*!


program define pathwimp, eclass

	version 15	

	syntax varlist(min=2 numeric) [if][in], ///
		dvar(varname numeric) ///
		d(real) ///
		dstar(real) ///
		yreg(string) ///
		[cvars(varlist numeric)] ///
		[NOINTERaction] ///
		[cxd] ///
		[cxm] ///
		[sampwts(varname numeric)]  ///
		[censor] ///
		[reps(integer 200)] ///
		[strata(varname numeric)] ///
		[cluster(varname numeric)] ///
		[level(cilevel)] ///
		[seed(passthru)] ///
		[saving(string)] ///
		[detail]
		
	qui {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
	}
	
	gettoken yvar mvars : varlist
	
	local num_mvars = wordcount("`mvars'")

	if (`num_mvars' > 5) {
		display as error "pathwimp only supports a maximum of 5 mvars"
		error 198
	}
	
	local i = 1
	foreach v of local mvars {
		local mvar`i' `v'
		local ++i
	}
	
	if ("`yreg'"=="logit") {
		confirm variable `yvar'
		qui levelsof `yvar', local(levels)
		if "`levels'" != "0 1" & "`levels'" != "1 0" {
			display as error "The outcome variable `yvar' is not binary and coded 0/1"
			error 198
		}
	}
	
	local yregtypes regress logit
	local nyreg : list posof "`yreg'" in yregtypes
	if !`nyreg' {
		display as error "Error: yreg must be chosen from: `yregtypes'."
		error 198		
	}
	else {
		local mreg : word `nyreg' of `yregtypes'
	}

	confirm variable `dvar'
	qui levelsof `dvar', local(levels)
	if "`levels'" != "0 1" & "`levels'" != "1 0" {
		display as error "The variable `dvar' is not binary and coded 0/1"
		error 198
		}
		
	/***PRINT MODELS***/
	if ("`detail'" != "") {
	
		if ("`cxd'"!="") {	
			foreach c in `cvars' {
				tempvar dX`c'_dis
				qui gen `dX`c'_dis' = `dvar' * `c' if `touse'
				local cxd_vars_dis `cxd_vars_dis' `dX`c'_dis'
			}
		}
		
		tempvar wts_dis
		qui gen `wts_dis' = 1 if `touse'
		if ("`sampwts'" != "") {
			qui replace `wts_dis' = `wts_dis' * `sampwts' if `touse'
			qui sum `wts_dis' if `touse'
			qui replace `wts_dis' = `wts_dis' / r(mean) if `touse'
		}
		
		di ""
		di "Model for `dvar' given cvars:"
		logit `dvar' `cvars' [pw=`wts_dis'] if `touse'
		
		di ""
		di "Model for `yvar' given {cvars `dvar'}:"
		if ("`yreg'"=="regress") {
			reg `yvar' `dvar' `cvars' `cxd_vars_dis' [pw=`wts_dis'] if `touse'
		}

		if ("`yreg'"=="logit") {
			glm `yvar' `dvar' `cvars' `cxd_vars_dis' [pw=`wts_dis'] if `touse', family(b) link(l)
		}
		
		pathwimpbs `yvar' `mvars' if `touse', ///
			dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
			d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
			sampwts(`sampwts') `censor' `detail'
	}
		
	/***COMPUTE POINT AND INTERVAL ESTIMATES***/
	if (`num_mvars' == 1) {
	
		if ("`saving'" != "") {
			bootstrap ///
				ATE=r(ate) ///
				NDE=r(nde) ///
				NIE=r(nie), ///
					reps(`reps') strata(`strata') cluster(`cluster') level(`level') `seed' ///
					saving(`saving', replace) ///
					noheader notable: ///
						pathwimpbs `yvar' `mvars' if `touse', ///
							dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
							d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
							sampwts(`sampwts') `censor'
		}
	
		if ("`saving'" == "") {
			bootstrap ///
				ATE=r(ate) ///
				NDE=r(nde) ///
				NIE=r(nie), ///
					reps(`reps') strata(`strata') cluster(`cluster') level(`level') `seed' ///
					noheader notable: ///
						pathwimpbs `yvar' `mvars' if `touse', ///
							dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
							d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
							sampwts(`sampwts') `censor'
		}
	}
		
	if (`num_mvars' == 2) {

		if ("`saving'" != "") {
			bootstrap ///
				ATE=r(ate) ///
				PSE_DY=r(pse_DY) ///
				PSE_DM2Y=r(pse_DM2Y) ///
				PSE_DM1Y=r(pse_DM1Y), ///
					reps(`reps') strata(`strata') cluster(`cluster') level(`level') `seed' ///
					saving(`saving', replace) ///
					noheader notable: ///
						pathwimpbs `yvar' `mvars' if `touse', ///
							dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
							d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
							sampwts(`sampwts') `censor'
		}
	
		if ("`saving'" == "") {
			bootstrap ///
				ATE=r(ate) ///
				PSE_DY=r(pse_DY) ///
				PSE_DM2Y=r(pse_DM2Y) ///
				PSE_DM1Y=r(pse_DM1Y), ///
					reps(`reps') strata(`strata') cluster(`cluster') level(`level') `seed' ///
					noheader notable: ///
						pathwimpbs `yvar' `mvars' if `touse', ///
							dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
							d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
							sampwts(`sampwts') `censor'
		}
	}

	if (`num_mvars' == 3) {

		if ("`saving'" != "") {
			bootstrap ///
				ATE=r(ate) ///
				PSE_DY=r(pse_DY) ///
				PSE_DM3Y=r(pse_DM3Y) ///				
				PSE_DM2Y=r(pse_DM2Y) ///
				PSE_DM1Y=r(pse_DM1Y), ///
					reps(`reps') strata(`strata') cluster(`cluster') level(`level') `seed' ///
					saving(`saving', replace) ///
					noheader notable: ///
						pathwimpbs `yvar' `mvars' if `touse', ///
							dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
							d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
							sampwts(`sampwts') `censor'
		}
	
		if ("`saving'" == "") {
			bootstrap ///
				ATE=r(ate) ///
				PSE_DY=r(pse_DY) ///
				PSE_DM3Y=r(pse_DM3Y) ///				
				PSE_DM2Y=r(pse_DM2Y) ///
				PSE_DM1Y=r(pse_DM1Y), ///
					reps(`reps') strata(`strata') cluster(`cluster') level(`level') `seed' ///
					noheader notable: ///
						pathwimpbs `yvar' `mvars' if `touse', ///
							dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
							d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
							sampwts(`sampwts') `censor'
		}
	}

	if (`num_mvars' == 4) {

		if ("`saving'" != "") {
			bootstrap ///
				ATE=r(ate) ///
				PSE_DY=r(pse_DY) ///
				PSE_DM4Y=r(pse_DM4Y) ///				
				PSE_DM3Y=r(pse_DM3Y) ///
				PSE_DM2Y=r(pse_DM2Y) ///
				PSE_DM1Y=r(pse_DM1Y), ///
					reps(`reps') strata(`strata') cluster(`cluster') level(`level') `seed' ///
					saving(`saving', replace) ///
					noheader notable: ///
						pathwimpbs `yvar' `mvars' if `touse', ///
							dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
							d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
							sampwts(`sampwts') `censor'
		}
	
		if ("`saving'" == "") {
			bootstrap ///
				ATE=r(ate) ///
				PSE_DY=r(pse_DY) ///
				PSE_DM4Y=r(pse_DM4Y) ///								
				PSE_DM3Y=r(pse_DM3Y) ///				
				PSE_DM2Y=r(pse_DM2Y) ///
				PSE_DM1Y=r(pse_DM1Y), ///
					reps(`reps') strata(`strata') cluster(`cluster') level(`level') `seed' ///
					noheader notable: ///
						pathwimpbs `yvar' `mvars' if `touse', ///
							dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
							d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
							sampwts(`sampwts') `censor'
		}
	}

	if (`num_mvars' == 5) {

		if ("`saving'" != "") {
			bootstrap ///
				ATE=r(ate) ///
				PSE_DY=r(pse_DY) ///
				PSE_DM5Y=r(pse_DM5Y) ///				
				PSE_DM4Y=r(pse_DM4Y) ///				
				PSE_DM3Y=r(pse_DM3Y) ///
				PSE_DM2Y=r(pse_DM2Y) ///
				PSE_DM1Y=r(pse_DM1Y), ///
					reps(`reps') strata(`strata') cluster(`cluster') level(`level') `seed' ///
					saving(`saving', replace) ///
					noheader notable: ///
						pathwimpbs `yvar' `mvars' if `touse', ///
							dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
							d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
							sampwts(`sampwts') `censor'
		}
	
		if ("`saving'" == "") {
			bootstrap ///
				ATE=r(ate) ///
				PSE_DY=r(pse_DY) ///
				PSE_DM5Y=r(pse_DM5Y) ///		
				PSE_DM4Y=r(pse_DM4Y) ///								
				PSE_DM3Y=r(pse_DM3Y) ///				
				PSE_DM2Y=r(pse_DM2Y) ///
				PSE_DM1Y=r(pse_DM1Y), ///
					reps(`reps') strata(`strata') cluster(`cluster') level(`level') `seed' ///
					noheader notable: ///
						pathwimpbs `yvar' `mvars' if `touse', ///
							dvar(`dvar') cvars(`cvars') yreg(`yreg') ///
							d(`d') dstar(`dstar') `cxd' `cxm' `nointeraction' ///
							sampwts(`sampwts') `censor'
		}
	}
	
	estat bootstrap, p noheader
	
end pathwimp
