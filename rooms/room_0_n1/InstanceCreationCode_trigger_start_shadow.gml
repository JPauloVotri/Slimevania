object = oPlayer;

on_trigger = function(_instance) {
	var _shadow = instance_find(oShadow, 0);
	
	_shadow.MOVEMENT_SPEED = 3;
};