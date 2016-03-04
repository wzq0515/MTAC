mtype = {processing, commit};
mtype status = commit;
int balance = 10000;
active[10] proctype withdraw() {
	int amount = 3000;
	if :: status==commit -> 
		status = processing;
		if :: balance >= amount ->
			balance = balance-amount;
			printf("Try to withdraw %d\n", amount);
			:: else ->
			printf("Fail to withdraw\n");
		fi;
		printf("pid : %d\tbalance : %d\n",_pid, balance);
		status = commit;
		assert(balance >= 0);
	fi;
}