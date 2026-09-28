if (droping) {
	velocity.y = min(velocity.y + GRAVITY, MAX_FALL_SPEED);

	velocityReminder.addRW(velocity);
	var _move = velocityReminder.abs();
	_move.flrRW();
	_move.componentMultiplyRW(velocityReminder.sign());

	if (_move.y != 0) {
		velocityReminder.y -= _move.y;
	
		var _dir = sign(_move.y);
	
		while (_move.y != 0) {
			var _instance = instance_place(x, y + _dir, all);
		
			if (_instance != noone && _instance.object_index == oWaterSpring) {
				y += _dir;
				break;
			} else if (_instance != noone) {
				inst.alarm[0] = 120;
				instance_destroy();
			}
		
			y += _dir;
			_move.y -= _dir;
		}
	}
}