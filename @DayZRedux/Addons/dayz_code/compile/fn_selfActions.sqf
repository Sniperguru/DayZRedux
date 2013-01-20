scriptName "Functions\misc\fn_selfActions.sqf";
/***********************************************************
	ADD ACTIONS FOR SELF
	- Function
	- [] call fnc_usec_selfActions;
************************************************************/
private["_menClose","_hasBandage","_hasEpi","_hasMorphine","_hasBlood","_vehicle","_inVehicle","_color","_part"];

// Stop a common form of performing multiple actions during a previous action
//_curAnim = animationState player;
//_inMedicAnim = (_curAnim == "ainvpknlmstpslaywrfldnon_medic");

_vehicle = vehicle player;
_inVehicle = (_vehicle != player);
_bag = unitBackpack player;
_classbag = typeOf _bag;
_isWater = 		(surfaceIsWater (position player)) or dayz_isSwimming;
_hasAntiB = 	"ItemAntibiotic" in magazines player;
_hasFuelE = 	"ItemJerrycanEmpty" in magazines player;
_hasRawMeat = 	"FoodSteakRaw" in magazines player;
_hasKnife = 	"ItemKnife" in items player;
_hasToolbox = 	"ItemToolbox" in items player;
_hasChloroform = "ItemChloroform" in magazines player;
_hasMatches = 	"ItemMatchbox" in items player;
_onLadder =		(getNumber (configFile >> "CfgMovesMaleSdr" >> "States" >> (animationState player) >> "onLadder")) == 1;
_nearLight = 	nearestObject [player,"LitObject"];
_canPickLight = false;


if (!isNull _nearLight) then {
	if (_nearLight distance player < 4) then {
		_canPickLight = isNull (_nearLight getVariable ["owner",objNull]);
	};
};
_canDo = (!r_drag_sqf and !r_player_unconscious and !_onLadder);

//Grab Flare
if (_canPickLight and !dayz_hasLight) then {
	if (s_player_grabflare < 0) then {
		_text = getText (configFile >> "CfgAmmo" >> (typeOf _nearLight) >> "displayName");
		s_player_grabflare = player addAction [format[localize "str_actions_medical_15",_text], "\z\addons\dayz_code\actions\flare_pickup.sqf",_nearLight, 1, false, true, "", ""];
		s_player_removeflare = player addAction [format[localize "str_actions_medical_17",_text], "\z\addons\dayz_code\actions\flare_remove.sqf",_nearLight, 1, false, true, "", ""];
	};
} else {
	player removeAction s_player_grabflare;
	player removeAction s_player_removeflare;
	s_player_grabflare = -1;
	s_player_removeflare = -1;
};

if (!isNull cursorTarget and !_inVehicle and (player distance cursorTarget < 4)) then {	//Has some kind of target
	_isHarvested = cursorTarget getVariable["meatHarvested",false];
	_isVehicle = cursorTarget isKindOf "AllVehicles";
	_isMan = cursorTarget isKindOf "Man";
	_ownerID = cursorTarget getVariable ["characterID","0"];
	_isAnimal = cursorTarget isKindOf "Animal";
	_isZombie = cursorTarget isKindOf "zZambie_base";
	_isDestructable = cursorTarget isKindOf "BuiltItems";
	_isTent = ((cursorTarget isKindOf "Land_Cont_RX") or (cursorTarget isKindOf "Land_Cont2_RX"));
	_isStorageBox = (cursorTarget isKindOf "Land_Mag_RX");
	_isFuel = false;
	_isAlive = alive cursorTarget;
	_text = getText (configFile >> "CfgVehicles" >> typeOf cursorTarget >> "displayName");
	if (_hasFuelE) then {
		_isFuel = (cursorTarget isKindOf "Land_Ind_TankSmall") or (cursorTarget isKindOf "Land_fuel_tank_big") or (cursorTarget isKindOf "Land_fuel_tank_stairs") or (cursorTarget isKindOf "Land_wagon_tanker");
	};
	//diag_log ("OWNERID = " + _ownerID + " CHARID = " + dayz_characterID + " " + str(_ownerID == dayz_characterID));
	
	//Allow player to delete objects
	if(_isDestructable and _hasToolbox and _canDo) then {
		if (s_player_deleteBuild < 0) then {
			s_player_deleteBuild = player addAction [format[localize "str_actions_delete",_text], "\z\addons\dayz_code\actions\remove.sqf",cursorTarget, 1, true, true, "", ""];
		};
	} else {
		player removeAction s_player_deleteBuild;
		s_player_deleteBuild = -1;
	};
	
	/*
	//Allow player to force save
	if((_isVehicle or _isTent) and _canDo and !_isMan) then {
		if (s_player_forceSave < 0) then {
			s_player_forceSave = player addAction [format[localize "str_actions_save",_text], "\z\addons\dayz_code\actions\forcesave.sqf",cursorTarget, 1, true, true, "", ""];
		};
	} else {
		player removeAction s_player_forceSave;
		s_player_forceSave = -1;
	};
	*/

	//Allow player to set tent ablaze
	if(_isTent and _hasMatches and _canDo and !_isMan) then {
		if (s_player_igniteTent < 0) then {
			s_player_igniteTent = player addAction [format[localize "str_actions_ignite_tent"], "\z\addons\dayz_code\actions\tent_ignite.sqf",cursorTarget, 1, true, true, "", ""];
		};
	} else {
		player removeAction s_player_igniteTent;
		s_player_igniteTent = -1;
	};

	//Allow player to set storage box ablaze
	if(_isStorageBox and _hasMatches and _canDo and !_isMan and _isAlive) then {
		if (s_player_igniteBox < 0) then {
			s_player_igniteBox = player addAction [format[localize "str_actions_ignite_box"], "\z\addons\dayz_code\actions\box_ignite.sqf",cursorTarget, 1, true, true, "", ""];
		};
	} else {
		player removeAction s_player_igniteBox;
		s_player_igniteBox = -1;
	};
	
	//Allow player to fill jerrycan
	if(_hasFuelE and _isFuel and _canDo) then {
		if (s_player_fillfuel < 0) then {
			s_player_fillfuel = player addAction [localize "str_actions_self_10", "\z\addons\dayz_code\actions\jerry_fill.sqf",[], 1, false, true, "", ""];
		};
	} else {
		player removeAction s_player_fillfuel;
		s_player_fillfuel = -1;
	};
	
	if (!alive cursorTarget and _isAnimal and _hasKnife and !_isHarvested and _canDo) then {
		if (s_player_butcher < 0) then {
			s_player_butcher = player addAction [localize "str_actions_self_04", "\z\addons\dayz_code\actions\gather_meat.sqf",cursorTarget, 3, true, true, "", ""];
		};
	} else {
		player removeAction s_player_butcher;
		s_player_butcher = -1;
	};
	
	//Fireplace Actions check
	if(inflamed cursorTarget and _hasRawMeat and _canDo) then {
		if (s_player_cook < 0) then {
			s_player_cook = player addAction [localize "str_actions_self_05", "\z\addons\dayz_code\actions\cook.sqf",cursorTarget, 3, true, true, "", ""];
		};
	} else {
		player removeAction s_player_cook;
		s_player_cook = -1;
	};
	if(cursorTarget == dayz_hasFire and _canDo) then {
		if ((s_player_fireout < 0) and !(inflamed cursorTarget) and (player distance cursorTarget < 3)) then {
			s_player_fireout = player addAction [localize "str_actions_self_06", "\z\addons\dayz_code\actions\fire_pack.sqf",cursorTarget, 0, false, true, "",""];
		};
	} else {
		player removeAction s_player_fireout;
		s_player_fireout = -1;
	};
	
	//Packing my tent
	if(((cursorTarget isKindOf "Land_Cont_RX") or (cursorTarget isKindOf "Land_Cont2_RX")) and _canDo and _ownerID == dayz_characterID) then {
		if ((s_player_packtent < 0) and (player distance cursorTarget < 3)) then {
			s_player_packtent = player addAction [localize "str_actions_self_07", "\z\addons\dayz_code\actions\tent_pack.sqf",cursorTarget, 0, false, true, "",""];
		};
	} else {
		player removeAction s_player_packtent;
		s_player_packtent = -1;
	};

	//Retrieving my box
	if((cursorTarget isKindOf "Land_Mag_RX") and _canDo and _ownerID == dayz_characterID and _isAlive) then {
		if ((s_player_retrievebox < 0) and (player distance cursorTarget < 3)) then {
			s_player_retrievebox = player addAction [localize "str_actions_self_11", "\z\addons\dayz_code\actions\box_retrieve.sqf",cursorTarget, 0, false, true, "",""];
		};
	} else {
		player removeAction s_player_retrievebox;
		s_player_retrievebox = -1;
	};
	

	//Flipping vehicle
	if(cursorTarget isKindOf "LandVehicle" and _canDo) then {
		_validVehicle = (cursorTarget isKindOf "Car") or (cursorTarget isKindOf "Motorcycle");
		_playerVectorUp = (vectorUp player) select 2;
		_vehicleVectorUp = (vectorUp cursorTarget) select 2;
		_flippable = (_vehicleVectorUp < 0.6);
		_noCrew = (count (crew cursorTarget) == 0);
		
		if (_flippable && _noCrew) then {
			if ((s_player_flipveh < 0) and (player distance cursorTarget < 4)) then {
				s_player_flipveh = player addAction [format[localize "str_action_flipveh",_text], "\z\addons\dayz_code\actions\flip_vehicle.sqf",cursorTarget, 0, false, true, "",""];
			};
		} else {
			player removeAction s_player_flipveh;
			s_player_flipveh = -1;
		};
	} else {
		player removeAction s_player_flipveh;
		s_player_flipveh = -1;
	};

	//Repairing Vehicles
	if ((dayz_myCursorTarget != cursorTarget) and !_isMan and _isVehicle) then {
		_vehicle = cursorTarget;
		{dayz_myCursorTarget removeAction _x} forEach s_player_repairActions;s_player_repairActions = [];
		dayz_myCursorTarget = _vehicle;
		_hitpoints = _vehicle call vehicle_getHitpoints;

		_handle = dayz_myCursorTarget addAction ["Inspect Vehicle", "\z\addons\dayz_code\actions\inspectvehicle.sqf",[_vehicle,_hitpoints], 0, false, true, "",""];
		s_player_repairActions set [count s_player_repairActions,_handle];

		_allFixed = true;
		{
			_damage = [_vehicle,_x] call object_getHit;
			//if (_damage > 0) then {
				_color = "";
				_part = "PartGeneric";
				_cmpt = _x;
				_damagePercent = round((1 - _damage) * 100);
				if(["Body",_x,false] call fnc_inString) then {
					_part = "PartGeneric";
					_cmpt = "Body";
					if (_damagePercent < 95) then {_allFixed = false};
				};
				if(["Engine",_x,false] call fnc_inString) then {
					_part = "PartEngine";
					_cmpt = "Engine";
					if (_damagePercent < 95) then {_allFixed = false};
				};
				if(["HRotor",_x,false] call fnc_inString) then {
					_part = "PartVRotor";
					_cmpt = "Main Rotor Assembly";
					if (_damagePercent < 95) then {_allFixed = false};
				};
				if(["Avionics",_x,false] call fnc_inString) then {
					_part = "PartGeneric";
					_cmpt = "Avionics";
					if (_damagePercent < 95) then {_allFixed = false};
				};
				if(["Missiles",_x,false] call fnc_inString) then {
					_part = "PartGeneric";
					_cmpt = "Missiles";
					if (_damagePercent < 95) then {_allFixed = false};
				};
				if(["VRotor",_x,false] call fnc_inString) then {
					_part = "PartGeneric";
					_cmpt = "Rear Rotor Assembly";
					if (_damagePercent < 95) then {_allFixed = false};
				};
				if(["Hull",_x,false] call fnc_inString) then {
					_part = "PartGeneric";
					_cmpt = "Hull";
					if (_damagePercent < 95) then {_allFixed = false};
				};
				if(["Fuel",_x,false] call fnc_inString) then {
					_part = "PartFueltank";
					_cmpt = "Fuel Tank";
					if (_damagePercent < 95) then {_allFixed = false};
				};
				if(["Wheel",_x,false] call fnc_inString) then {
					_part = "PartWheel";
					_cmpt = "Wheel";
					_array = toArray _x;
					_newArray = [];
					for "_i" from 3 to ((count _array) - 1) do {_newArray set [count _newArray,(_array select _i)]};
					_array = _newArray;
					_newArray = [];
					for "_i" from 0 to ((count _array) - 6) do {_newArray set [count _newArray,(_array select _i)]};
					_toStr = toString _newArray;
					_toStr = switch (_toStr) do {
						default {_toStr};
						case "LF": {"Left Front"};
						case "RF": {"Right Front"};
						case "LF2": {"Left Front 2nd"};
						case "RF2": {"Right Front 2nd"};
						case "LB": {"Left Back"};
						case "RB": {"Right Back"};
						case "LM": {"Left Middle"};
						case "RM": {"Right Middle"};
						case "F": {"Front"};
						case "B": {"Back"};
					};
					_cmpt = _cmpt + " " + _toStr;
					if (_damagePercent < 95) then {_allFixed = false};
				};
				if(["Glass",_x,false] call fnc_inString) then {
					_part = "PartGlass";

					_fullPartName = toArray _x;
					_glassName = [];
					for "_i" from 3 to ((count _fullPartName) - 1) do {_glassName set [count _glassName ,(_fullPartName select _i)]};
					_cmpt = toString _glassName;

					if (_damagePercent < 95) then {_allFixed = false};
				};
				if (_part in magazines player and _damage > 0) then {
					if (_damage > 0.3) then {_color = "color='#ffff00'"};
					if (_damage > 0.6) then {_color = "color='#ff0000'";};
					_string = format[localize "str_actions_medical_09",_cmpt,_color];
					_handle = dayz_myCursorTarget addAction [_string, "\z\addons\dayz_code\actions\repair.sqf",[_vehicle,_part,_x], 0, false, true, "",""];
					s_player_repairActions set [count s_player_repairActions,_handle];
				};
			//};
			//diag_log(format["Checking Part X[%1] part[%2] cmpt[%3] damage[%3] -- State: %4",_x,_part,_cmpt,_damage,_allFixed]);
		} forEach _hitpoints;
		if (_allFixed) then {
			_vehicle setDamage 0;
		};
	};

	if (_isMan and _isAlive and !_isZombie and _hasChloroform and _canDo) then {
		if (s_player_chloroform < 0) then {
			s_player_chloroform = player addAction [localize "str_action_chloroform", "\z\addons\dayz_code\actions\chloroform.sqf",cursorTarget, 0, false, true, "",""];
		};
	} else {
		player removeAction s_player_chloroform;
		s_player_chloroform = -1;
	};
	
	if (_isMan and !_isAlive and !_isZombie) then {
		if (s_player_studybody < 0) then {
			s_player_studybody = player addAction [localize "str_action_studybody", "\z\addons\dayz_code\actions\study_body.sqf",cursorTarget, 0, false, true, "",""];
		};
	} else {
		player removeAction s_player_studybody;
		s_player_studybody = -1;
	};	
} else {
	//Engineering
	{dayz_myCursorTarget removeAction _x} forEach s_player_repairActions;s_player_repairActions = [];
	dayz_myCursorTarget = objNull;
	//Others
	//player removeAction s_player_forceSave;
	//s_player_forceSave = -1;
	player removeAction s_player_igniteTent;
	s_player_igniteTent = -1;
	player removeAction s_player_igniteBox;
	s_player_igniteBox = -1;
	player removeAction s_player_deleteBuild;
	s_player_deleteBuild = -1;
	player removeAction s_player_butcher;
	s_player_butcher = -1;
	player removeAction s_player_cook;
	s_player_cook = -1;
	player removeAction s_player_fireout;
	s_player_fireout = -1;
	player removeAction s_player_packtent;
	s_player_packtent = -1;
	player removeAction s_player_fillfuel;
	s_player_fillfuel = -1;
	player removeAction s_player_studybody;
	s_player_studybody = -1;
	player removeAction s_player_flipveh;
	s_player_flipveh = -1;
	player removeAction s_player_chloroform;
	s_player_chloroform = -1;
};