mtype = {originalPlace, overTheRiver}; // 위치를 나타내는 mtype

typedef Object { //각 오브젝트와 그 위치를 저장
	mtype location = originalPlace;
}

chan boatCurrent = [1] of { mtype , Object}; // 강을 건널 때 사용하는 채널
Object Farmer, Wolf, Goat, Cabbage; // 강을 건널 객체들
bool flag = true; // 모두가 강을 건너면 false가 되고 프로그램을 종료한다.

inline cross(location, x) { // 강을 건너는 작업을 하는 inline. location : 배의 위치, x : 강을 건너는 object
	// 농부의 경우 배가 강을 건널때 언제나 강을 건너야 하기 때문에 
	// 실제로 배는 2개의 object를 옮길 수 있지만 농부 + 다른 오브젝트가 이동시 다른 오브젝트를 x로 설정함.
	// 농부 혼자 강을 건널 때는 x를 농부로 설정함
	if 
	:: atomic{
		// object와 배 모두 원래의 장소에 있을 경우 , 강 건너로 위치를 옮겨준다
		location == originalPlace && x.location == originalPlace ->  
		x.location = overTheRiver;
		Farmer.location = overTheRiver;
		boatCurrent!overTheRiver,x;
	}
	:: atomic{
		// object와 배 모두 강 건너에 있을 경우 , 원래의 장소로 위치를 옮겨준다
		location == overTheRiver && x.location == overTheRiver ->
		x.location = originalPlace;
		Farmer.location = originalPlace;
		boatCurrent!originalPlace,x;
	}
	fi
}
active proctype wolf() { // 늑대가 염소를 잡아먹으면 assert validation이 발생한다.
	do 
	:: flag ->
		if :: Farmer.location != Wolf.location && Wolf.location == Goat.location ->
			assert(false);
		:: else -> skip
		fi
	:: else -> break;
	od
}
active proctype goat() { // 염소가 양배추를 먹으면 assert validation이 발생한다.
	do 
	:: flag ->
		if ::Farmer.location != Goat.location && Goat.location == Cabbage.location ->
			assert(false);
		::else -> skip
		fi
	:: else -> break;
	od
} 
active proctype boat() { // 조건에 따라 배가 누구를 실어보낼지 결정하는 프로세스
	mtype location = originalPlace;
	Object passenger;
	// 문제의 조건에 따라 조건을 설정하고 cross를 불러서 강을 건너는 작업을 한다. 
	// 만약 모두가 조건을 만족하면 flag를 false로 바꾸고 do loop를 종료한다. 
	do:: flag ->
		if
		:: Goat.location == Cabbage.location && Goat.location == Wolf.location && Goat.location == location ->
		// 늑대, 염소, 양배추가 모두 같이 있을 때 염소를 이동시켜야 한다. 
			cross(location, Goat);
			printf("Goat\n");
		:: Wolf.location == Cabbage.location && Goat.location != Cabbage.location && Wolf.location == location && location == originalPlace->
		// 늑대와 양배추가 함께 있고 배가 늑대와 양배추쪽에 있는 경우 늑대와 양배추쪽이 원래의 장소라면 늑대와 양배추 둘중 하나를 이동시킨다
			if
			:: cross(location, Wolf) -> printf("Wolf\n")
			:: cross(location, Cabbage) -> printf("Cabbage\n");
			fi
		:: Wolf.location == Cabbage.location && Goat.location != Cabbage.location && Goat.location == location && location == originalPlace->
		// 늑대와 양배추가 함께 있고 배가 염소쪽에 있는경우 염소쪽이 원래의 장소라면 염소를 이동시킨다
			cross(location, Goat); printf("Goat\n");
		:: Goat.location == Cabbage.location && Goat.location != Wolf.location && Cabbage.location == location->
		// 염소와 양배추가 함께 있게 된 경우 양배추를 이동시킨다. 
			cross(location, Cabbage);
			printf("Cabbage\n");
		:: Wolf.location == Goat.location && Goat.location != Cabbage.location && Wolf.location == location ->
		// 염소와 늑대가 함께 있게 된 경우 늑대를 이동시킨다. 
			cross(location, Goat);
			printf("Goat\n");
		:: else ->
		// 그 외의 경우는 모두 농부를 이동시킨다.
			cross(location, Farmer);
			printf("Farmer\n");
		fi
		if
		:: Goat.location == overTheRiver && Cabbage.location == overTheRiver && Wolf.location == overTheRiver->
		// 모두가 강을 건너면 loop를 종료한다.
			flag = false;
			break;
		:: else -> skip;
		fi;
		boatCurrent?location,passenger; // 채널을 통해 배의 위치를 update한다.
	od;
}
