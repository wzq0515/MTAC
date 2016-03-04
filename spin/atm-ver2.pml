mtype = {processing, commit};
mtype = {withdraw, deposit};

chan request = [0] of {mtype, int};
chan resources = [1] of {pid};
mtype status = commit;

active proctype Server() {
	int balance = 1000;
	int value;
	mtype request_type;
	pid p;
	do :: status == commit -> 
		resources?p;
	:: status == processing ->
		request?request_type,value;
		if :: request_type == withdraw ->
			if :: (balance > value) ->
				balance = balance - value;
				status = commit;
			:: else ->
				status = commit;
			fi;
		:: request_type == deposit ->
			balance = balance + value;
			status = commit;
		fi;
	od;
}

active proctype ATM_widthdraw() {
	do :: (status == commit) ->
		atomic {
			resources!_pid;
			status = processing;
		}
		request!withdraw,2000;
	od;
}
active proctype ATM_deposit() {
	do :: (status == commit) ->
		atomic {
			resources!_pid;
			status = processing;
		}
		request!deposit,2000;
	od;
}