mtype = {processing, commit};
mtype status = commit;
int balance = 10000;
active proctype withdraw() {
	int payment;
	if :: status==commit -> 
		status = processing;
		if:: payment = 12000 ->
			:: payment = 6000 ->
		fi;
		balance = balance-payment;
		printf("Try to withdraw %d\n", payment);
		printf("pid : %d\tbalance : %d\n",_pid, balance);
		status = commit;
	fi;
}
active proctype deposit() {
	if :: status==commit -> 
		status = processing;
		balance = balance + 2000;
		printf("Try to deposit 2000\n");
		printf("pid : %d\tbalance : %d\n",_pid, balance);
		status = commit;
	fi;
}
