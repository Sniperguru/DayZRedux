private["_vehicle","_part","_hitpoint","_type","_selection","_array"];
_array = 	_this select 3;
_vehicle = 	_array select 0;
_part =		_array select 1;
_hitpoint = _array select 2;
_type = typeOf _vehicle;

//Engineering
{dayz_myCursorTarget removeAction _x} forEach s_player_repairActions;s_player_repairActions = [];
dayz_myCursorTarget = objNull;

_hasToolbox = "ItemToolbox" in items player;
_hasPart = _part in magazines player;

if (_hasPart) then {
	if (!_hasToolbox) exitWith{
		cutText [format["You must have a Toolbox to repair a vehicle"], "PLAIN DOWN"];
	};

	player removeMagazine _part;

	//wait a bit
	
	player playActionNow "Medic";
	sleep 1;
	[player,"repair",0,false] call dayz_zombieSpeak;
	_id = [player,50,true,(getPosATL player)] spawn player_alertZombies;
	sleep 5;
	
	//Fix the part
	_selection = 	getText(configFile >> "cfgVehicles" >> _type >> "HitPoints" >> _hitpoint >> "name");
	_nameType = 		getText(configFile >> "cfgVehicles" >> _type >> "displayName");
	_namePart = 		getText(configFile >> "cfgMagazines" >> _part >> "displayName");
	
	dayzSetFix = [_vehicle,_selection,0];
	publicVariable "dayzSetFix";
	if (local _vehicle) then {
		dayzSetFix call object_setFixServer;
	};
	_vehicle setvelocity [0,0,1];

	//Success!
	cutText [format[localize "str_player_04",_namePart,_nameType], "PLAIN DOWN"];

	{dayz_myCursorTarget removeAction _x} forEach s_player_repairActions;s_player_repairActions = [];
	dayz_myCursorTarget = objNull;
} else {
	cutText [localize "str_player_03", "PLAIN DOWN"];
};
