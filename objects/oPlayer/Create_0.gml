// Herda os eventos do objeto pai
event_inherited();

GRAVITY = .15;
JUMP_SPEED = 5;
MAX_FALL_SPEED = 4;
MOVEMENT_SPEED = 2;

#region Inputs
    keys = {
        left: false,
        right: false,
        down: false,
        jump: false,
		usePower: false,
    };
	
	facing_x = 0;
#endregion

#region Powerups
	powersList = [];
	activePower = "";
	recharge = 0;
	hitWallY = false;
	
	// PowerDash
	dashing = false;
	dash_timer = 0;
	dash_duration = 0.2;
	dash_speed = 8;
	dash_dir_x = 0;
	dash_dir_y = 0;
	dash_recharge = 2;
#endregion