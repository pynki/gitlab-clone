#!/bin/bash

#####
PRIVATE_TOKEN="InsertYourPrivateTokenHere"
#####
URI_BASE="YourServersURIBase"
#####
CLONE_DIR="./gitlab-clone"
PARALLEL_CLONES=3
EXPECTED_MAX_GROUP_ID=150
SLEEP_TIME=5
STR_404='{"message":"404 Not found"}'
#####
GRP_COUNT=0
declare -A GROUPS_ARR
declare -A JOBS
##### Start #####
for i in $(seq 1 "$EXPECTED_MAX_GROUP_ID"); 
do			
	CURL_RESULT="$(curl --silent --header "PRIVATE-TOKEN: $PRIVATE_TOKEN" "$URI_BASE/api/v3/groups/$i")"
	echo $CURL_RESULT | grep -qw "$STR_404"			
	if [ ! $? -eq 0 ]; then
		((GRP_COUNT++))
		GROUPS_ARR[$i]=$CURL_RESULT
	fi	
done
echo "GRP_COUNT: $GRP_COUNT"
for j in "${!GROUPS_ARR[@]}"
do
	echo "Working on group with id: $j"
	PRO_COUNT="$(echo "${GROUPS_ARR[$j]}" | jq '.projects | length')"
	echo "PRO_COUNT: $PRO_COUNT"
  	for k in $(seq 1 $PRO_COUNT);  
    do  
		PRO="$(echo "${GROUPS_ARR[$j]}" | jq -r --arg K $k '.projects | .[$K | tonumber -1]')"
		PRO_PATH="$(echo "${GROUPS_ARR[$j]}" | jq -r --arg K $k '.projects | .[$K | tonumber -1] | .path')"
		PRO_NSP_PATH="$(echo "${GROUPS_ARR[$j]}" | jq -r --arg K $k '.projects | .[$K | tonumber -1] | .namespace.path')"
		PRO_URL_SSH="$(echo "${GROUPS_ARR[$j]}" | jq -r --arg K $k '.projects | .[$K | tonumber -1] | .ssh_url_to_repo')"
		echo "Project nsp/path selected: $PRO_NSP_PATH/$PRO_PATH ---> $PRO_URL_SSH"		
		#####
		mkdir -p -v $CLONE_DIR/$PRO_NSP_PATH/$PRO_PATH
		#####		
		git clone --recursive --progress $PRO_URL_SSH $CLONE_DIR/$PRO_NSP_PATH/$PRO_PATH 2> $CLONE_DIR/$PRO_NSP_PATH/$PRO_NSP_PATH_$PRO_PATH.log &		
		JOBS[$!]=$CLONE_DIR/$PRO_NSP_PATH/$PRO_PATH
		echo "Started job with pid $! --> $CLONE_DIR/$PRO_NSP_PATH/$PRO_PATH"
		JOB_COUNT=$(jobs -lr | wc -l)
		while [ "$JOB_COUNT" -ge "$PARALLEL_CLONES" ] 
		do
			JOBS_ACT="$(jobs -lrp)"
			if [ "$JOBS_ACT" != "$JOBS_OLD" ];
			then
				echo "Jobs running: $JOB_COUNT"
			fi
			for x in $(jobs -lrp)
			do
				if [ "$JOBS_ACT" != "$JOBS_OLD" ];
				then
					echo "     Job pid: $x --> ${JOBS[$x]}"
				fi
			done
			sleep "$SLEEP_TIME"
			JOB_COUNT=$(jobs -lr | wc -l)	
			JOBS_OLD=$JOBS_ACT		
		done
	done
done
JOB_COUNT=$(jobs -lr | wc -l)
while [ "$JOB_COUNT" -gt 0 ] 
do
	JOBS_ACT="$(jobs -lrp)"
	if [ "$(jobs -lrp)" != "$JOBS_OLD" ];
	then
		echo "Wait for remaining jobs running: $JOB_COUNT"
	fi
	for x in $(jobs -lrp)
	do
		if [ "$JOBS_ACT" != "$JOBS_OLD" ];
		then
			echo "     Job pid: $x --> ${JOBS[$x]}"
		fi
	done
	sleep "$SLEEP_TIME"
	JOB_COUNT=$(jobs -lr | wc -l)	
	JOBS_OLD=$JOBS_ACT		
done
wait
exit 0
#####  END  #####
