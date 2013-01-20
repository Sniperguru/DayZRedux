_isAir = vehicle player iskindof "Air";
_inVehicle = (vehicle player != player);
_fastRun = _this select 0;
_dateNow = (DateToNumber date);
_maxZombies = dayz_maxLocalZombies;
_age = -1;

// If they just got out of a vehicle, boost their per-player zombie limit by 5 in hopes of allowing insta-spawn zombies
if (dayz_inVehicle and !_inVehicle) then {
	dayz_spawnWait = -300;
	//_maxZombies = _maxZombies + 2;
};

dayz_inVehicle = _inVehicle;

//if (((time - dayz_spawnWait) < dayz_spawnDelay) or ((time - dayz_lootWait) < dayz_lootDelay)) exitWith {diag_log("Skipping Check since neither loot or zombies are ready");};
//if (((time - dayz_spawnWait) < dayz_spawnDelay) and ((time - dayz_lootWait) < dayz_lootDelay)) exitWith {};

//diag_log("SPAWN CHECKING: Starting");

//if (!_inVehicle) then {
	_position = getPosATL player;
	//waitUntil{_position nearObjectsReady 200};
	_nearby = _position nearObjects ["building",250]; //nearestObjects [player, ["building"], 200];
	_tooManyZs = {alive _x} count (_position nearEntities ["zZambie_Base",300]) > dayz_maxLocalZombies;
	//diag_log(format["SPAWN CHECK: Building count is %1", count _nearby]);
	{
		//diag_log("SPAWN CHECK: Start of Loop");
		_type = typeOf _x;
		_config = 		configFile >> "CfgBuildingLoot" >> _type;
		_canZombie = isClass (_config);
		_canLoot = ((count (getArray (_config >> "lootPos"))) > 0);
		_dis = _x distance player;

		//diag_log(format["SPAWN CHECK: %1 / %2 / %3", str(_type), str(_canZombie), str(_canLoot)]);

		if (_canLoot) then {	
			//diag_log("SPAWN LOOT: " + _type + " Building is lootable");
			//dayz_serverSpawnLoot = [_dis, _x];
			//publicVariableServer "dayz_serverSpawnLoot";
			_keepAwayDist = ((sizeOf _type)+5);
			_isNoone =	{isPlayer _x} count (_x nearEntities ["CAManBase",_keepAwayDist]) == 0;

			//diag_log(format["SPAWN LOOT: isNoone: %1 | keepAwayDist %2 | %3", str(_isNoone), _keepAwayDist, _type]);

			if (_isNoone) then {
				_looted = (_x getVariable ["looted",-0.1]);
				_cleared = (_x getVariable ["cleared",true]);
				/*
				if(isServer) then {
					_dateNow = (DateToNumber date);
					_age = (_dateNow - _looted) * 525948;
				} else {
					_dateNow = serverTime;
					_age = (_dateNow * 60) - _looted;
				};
				*/
				_dateNow = (DateToNumber date);
				_age = (_dateNow - _looted) * 525948;
				//diag_log ("SPAWN LOOT: " + _type + " Building is " + str(_age) + " old" );

				/*
				if ((_age > (10 * 12 + 15)) and (!_cleared)) then {
					_nearByObj = (getPosATL _x) nearObjects ["ReammoBox",((sizeOf _type)+5)];
					{deleteVehicle _x} forEach _nearByObj;
					_x setVariable ["cleared",true,true];
					_x setVariable ["looted",_dateNow,true];
				};
				if ((_age > (10 * 12 + 15)) and (_cleared)) then {
					//Register
					_x setVariable ["looted",_dateNow,true];
					//cleanup
					_handle = [_x,_fastRun] spawn building_spawnLoot;
					waitUntil{scriptDone _handle};
				};
				*/

				//if (_age > (9 * 12 + 15)) then {
				if (_age > 9) then {
					//diag_log("SPAWN LOOT: Spawning loot");
					//Register
					_x setVariable ["looted",_dateNow,true];
					//cleanup
					//_nearByObj = (getPosATL _x) nearObjects ["ReammoBox",((sizeOf _type)+5)];
					//{deleteVehicle _x} forEach _nearByObj;
					dayz_lootWait = time;
					_handle = [_x,_fastRun] spawn building_spawnLoot;
					waitUntil{scriptDone _handle};
				};
			};
		};

		if (_canZombie) then {
			if ((time - dayz_spawnWait) > dayz_spawnDelay and _dis < 200) then {
				if (dayz_spawnZombies < _maxZombies) then {
					if (!_tooManyZs) then {
						private["_zombied"];
						_zombied = (_x getVariable ["zombieSpawn",-0.1]);
						_dateNow = (DateToNumber date);
						_age = (_dateNow - _zombied) * 525948;
						//diag_log(format["Date: %1 | ZombieSpawn: %2 | age: %3 | building: %4 (%5)", _dateNow, _zombied, _age, str(_x), _dis]);
						//if (_age > (2 * 12 + 15)) then {
						if (_age > 2) then {
							_bPos = getPosATL _x;
							_zombiesNum = {alive _x} count (_bPos nearEntities ["zZambie_Base",(((sizeOf _type) * 2) + 10)]);
							if (_zombiesNum == 0) then {
								//Randomize Zombies
								_x setVariable ["zombieSpawn",_dateNow,true];
								_handle = [_x,_fastRun] spawn building_spawnZombies;
								waitUntil{scriptDone _handle};
							//} else {
								//_x setVariable ["zombieSpawn",_dateNow,true];
							};
						};
					};
				} else {
					dayz_spawnWait = time;
					//dayz_spawnZombies = 0;
				};
			};
		};

		if (!_fastRun) then {
			sleep 0.1;
		};
	} forEach _nearby;
//};