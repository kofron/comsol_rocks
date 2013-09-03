## submit is the intended target.  to generate an appropriate pbs script and submit
## via qsub, this makefile should be run as
##
## 	make model=path_to_mph_file nn=N np=P
##
## if you want to generate the qsub file only and not submit it, you can do that
## with 
##
##	make model=path_to_mph_file nn=N np=P generate_only=true
##
.PHONY: submit check-env generate-pbs-script run-qsub

all: submit
submit: check-env generate-pbs-script deploy

## Check to be sure that the user has specified a model file, number of nodes,
## and number of processors.
check-env: check-exists-model check-exists-nn check-exists-np \
	check-exists-job check-exists-email

check-exists-model:
ifndef model
	$(error please specify a model as argument with model=some_mph_file)
endif

check-exists-nn:
ifndef nn
	$(error please specify the number of nodes you want to request (nn=N))
endif

check-exists-np:
ifndef np
	$(error please specify the number of processors per node you want (np=N))
endif

check-exists-job:
ifndef job
	$(error please specify the job name you want (job=some_job_name))
endif

check-exists-email:
ifndef email
	$(error please specify an email address (email=E))
endif

## this target uses the arguments provided to turn the template file in the same
## directory into a pbs script which will then be submitted via qsub.
generate-pbs-script: 
	@cat comsol_rocks.tmpl | \
	sed 's/\*\*MODEL\*\*/$(model)/g' | \
	sed 's/\*\*NN\*\*/$(nn)/g' | \
	sed 's/\*\*NP\*\*/$(np)/g' | \
	sed 's/\*\*EMAIL\*\*/$(email)/g' | \
	sed 's/\*\*JOBNAME\*\*/$(job)/g' > \
	comsol_rocks_$(job)_$$PPID.pbs
	@echo output written to: comsol_rocks_$(job)_$$PPID.pbs

## deploy the generated file.  if all the user wanted was the generated file, just
## barf it out.  otherwise, run qsub on the result and send it to the cluster.
deploy:
ifndef generate_only
	@echo submitting job...
	@qsub comsol_rocks_$(job)_$$PPID.pbs
endif

