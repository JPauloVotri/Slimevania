var _dy = 0;
var _dx = 0;

switch (transition_dir) {
	case "right": _dx = 1; break;
	case "left": _dx = -1; break;
	case "down": _dy = 1; break;
	case "up": _dy = -1; break;
}

// Collision Event do oTransitionLine com oPlayer
global.direction_entrada = transition_dir;
global.player_pos_saida = (transition_dir == "left" || transition_dir == "right") ? oPlayer.y : oPlayer.x;

global.roomManager.change_room(room, _dx, _dy);