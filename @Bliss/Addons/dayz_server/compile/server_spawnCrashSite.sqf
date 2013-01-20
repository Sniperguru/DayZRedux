private["_position","_num","_config","_itemType","_itemChance","_weights","_index","_iArray","_crashModel","_lootTable","_guaranteedLoot","_randomizedLoot","_frequency","_variance","_spawnChance","_spawnMarker","_spawnRadius","_spawnFire","_permanentFire","_crashName"];

waitUntil{!isNil "BIS_fnc_selectRandom"};

_crashModel	= _this select 0;
_lootTable	= _this select 1;
_guaranteedLoot = _this select 2;
_randomizedLoot = _this select 3;
_frequency	= _this select 4;
_variance	= _this select 5;
_spawnChance	= _this select 6;
_spawnMarker	= _this select 7;
_spawnRadius	= _this select 8;
_spawnFire	= _this select 9;
_fadeFire	= _this select 10;

_crashName	= getText (configFile >> "CfgVehicles" >> _crashModel >> "displayName");

diag_log(format["CRASHSPAWNER: Starting spawn logic for '%1' with loot table '%2'", _crashName, _lootTable]);

while {true} do {
	private["_timeAdjust","_timeToSpawn","_spawnRoll","_crash","_hasAdjustment","_newHeight","_adjustedPos"];
	// Allows the variance to act as +/- from the spawn frequency timer
	_timeAdjust = round(random(_variance * 2) - _variance);
	_timeToSpawn = time + _frequency + _timeAdjust;

	diag_log(format["CRASHSPAWNER: %1%2 chance to spawn '%3' with loot table '%4' at %5", round(_spawnChance * 100), '%', _crashName, _lootTable, _timeToSpawn]);

	// Apprehensive about using one giant long sleep here given server time variances over the life of the server daemon
	while {time < _timeToSpawn} do {
		sleep 5;
	};

	_spawnRoll = random 1;

	// Percentage roll
	if (_spawnRoll <= _spawnChance) then {

		_position = [getMarkerPos _spawnMarker,0,_spawnRadius,10,0,2000,0] call BIS_fnc_findSafePos;

		diag_log(format["CRASHSPAWNER: Spawning '%1' with loot table '%2' NOW! (%3) at: %4", _crashName, _lootTable, time, str(_position)]);

		_crash = createVehicle [_crashModel,_position, [], 0, "CAN_COLLIDE"];

		// Randomize the direction the wreck is facing
		_crash setDir round(random 360);

		// Since "custom" wrecks (using the wreck model from a vehicle vs. prepared wrecks) can spawn in the ground
		// at Z coord 0, I set those wrecks to have a "height adjustment" stored in CfgVehicles for it so we can
		// spawn them higher than normal
		_config = configFile >> "CfgVehicles" >> _crashModel >> "heightAdjustment";
		_hasAdjustment =  isNumber(_config);
		_newHeight = 0;
		if (_hasAdjustment) then {
			_newHeight = getNumber(_config);
			//diag_log(format["DIAG: ADJUSTMENT FOUND FOR %1, IT IS: %2", _crashName, _newHeight]);
		};

		// Must setPos after a setDir otherwise the wreck won't level itself with the terrain
		_adjustedPos = [(_position select 0), (_position select 1), _newHeight];
		//diag_log(format["DIAG: Designated Position: %1", str(_adjustedPos)]);
		_crash setPos _adjustedPos;

		// I don't think this is needed, but it was in the original DayZ Crash logic
		dayz_serverObjectMonitor set [count dayz_serverObjectMonitor,_crash];

		_crash setVariable ["ObjectID",1,true];

		if (_spawnFire) then {
			dayzFire = [_crash,2,time,false,_fadeFire];
			publicVariable "dayzFire";
			nul=dayzFire spawn BIS_Effects_Burn;
			_crash setvariable ["fadeFire",_fadeFire,true];
		};

		_num		= round(random _randomizedLoot) + _guaranteedLoot;
		_config		= configFile >> "CfgBuildingLoot" >> _lootTable;
		_itemType	= [] + getArray (_config >> "itemType");
		_itemChance	= [] + getArray (_config >> "itemChance");

		waituntil {!isnil "fnc_buildWeightedArray"};

		for "_x" from 1 to _num do {
			//create loot
			//_index = _weights call BIS_fnc_selectRandom;
			//diag_log(format["DIAG: _index => %1", str(_index)]);

			private["_totalItems","_randomNum"];

			_weights	= [];
			_weights	= [_itemType,_itemChance] call fnc_buildWeightedArray;
			_totalItems	= (count _weights) - 1;
			_randomNum	= round(random _totalItems);
			_index		= _weights select _randomNum;
			//diag_log(format["DIAG: Total Items: %1 | Random Num: %2 | Index: %3 | Selection: %4 | Weights: %5", _totalItems, _randomNum, _index, str(_itemType select _index), count _weights]);

			_iArray = (_itemType select _index);
			_iArray set [2,_position];
			_iArray set [3,5]; // Spawn radius: May need to expose this as configurable or use sizeOf(_crashModel) here.
			_iArray set [4, "CrashSiteLoot"]; // Custom for Redux to ensure more weapon magazines spawn with heli crash weapons
			//diag_log(format["DIAG: _iArray => %1 <=", str(_iArray)]);
			_iArray call spawn_loot;

			diag_log(format["CRASHSPAWNER: Loot spawn at '%1' with loot table '%2': %3 (%4)", _crashName, _lootTable, _iArray select 0, _iArray select 1]); 

			_nearby = _position nearObjects ["ReammoBox", sizeOf(_crashModel)];
			{
				_x setVariable ["permaLoot",true];
			} forEach _nearBy;
		};

	} else {
		diag_log(format["CRASHSPAWNER: Roll chance to spawn '%1' with loot table '%2' failed", _crashName, _lootTable]);
	};
};