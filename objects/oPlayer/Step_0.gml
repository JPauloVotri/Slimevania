#region Inputs
    keys.left = keyboard_check(ord("A"));
    keys.right = keyboard_check(ord("D"));
    keys.down = keyboard_check(ord("S"));
	keys.up = keyboard_check(ord("W"));
    keys.jump = keyboard_check_pressed(vk_space);
	
	if (recharge <= 0) {
		keys.usePower = keyboard_check_pressed(vk_shift);
	};
#endregion

#region Cálculo do movimento
    var _dir_x = keys.right - keys.left;
	var _dir_y = keys.down - keys.up;
	
	
	if (_dir_x != 0) { facing_x = _dir_x };

	if (!dashing) {
		velocity.x = _dir_x * MOVEMENT_SPEED;
		velocity.y = min(velocity.y + GRAVITY, MAX_FALL_SPEED);
	}

    if (on_solid() && velocity.y > 0) {
        var isOnOneWay = place_meeting(x, y + 1, oOneWayBlock);

        if (keys.jump) {
            collide_y();
            velocity.y = -JUMP_SPEED;
        } else if (isOnOneWay && keys.down) {
            y++;
        } else {
            collide_y();
        }
    }
#endregion

#region Uso de powerups
	if (recharge > 0) {
		recharge -= delta_time / 1000000;
	
		if (recharge <= 0) recharge = 0;
	};
	
	if (keys.usePower && activePower != "") {
		var _usePowers = new PowerUP();
		_usePowers.use_power_up(self.id);
	};
	
	if (dashing) {
		dash_timer -= delta_time / 1000000;
		
		var _vel_y = noone;
		var _vel_x = noone;
		
		if (_dir_y != 0) {
			_vel_y = velocity.y == 0 ? 1 : velocity.y;
		}
		
		if (_dir_x != 0) {
			_vel_x = velocity.x == 0 ? 1 : velocity.x;
		}
		
		var _inst_y = instance_place(x, y + _vel_y, oBlock);
		var _inst_x = instance_place(x + _vel_x, y, oBlock);
		
		if (_inst_y) {
			if (!_inst_y.object_index == oCrackedBlock) {
				if (velocity.y != 0 && _inst_y) {
					collide_y();
					var _move = true;
			
					while (_move) {
						var _svel = sign(velocity.y);
			
						y += _svel;
				
						if (!instance_place(x, y + velocity.y, oBlock)) {
							hitWallY = true;
							_move = false;
						}
					}
				};
			} else if (_inst_y.object_index == oCrackedBlock) {
				array_push(global.blocos_quebrados, _inst_y.id.block_id);
				instance_destroy(_inst_y.id);
			};
		};
		
		if (_inst_x) {
			if (_inst_x.object_index == oCrackedBlock) {
				array_push(global.blocos_quebrados, _inst_x.id.block_id);
				instance_destroy(_inst_x.id);
			};
		};
	
		if (dash_timer <= 0 || hitWallY) {
			dashing = false;
			velocity.x = 0;
			velocity.y = 0;
			dash_timer = 0;
			hitWallY = false;
		};
	}
#endregion

move(velocity);

keys.usePower = false;