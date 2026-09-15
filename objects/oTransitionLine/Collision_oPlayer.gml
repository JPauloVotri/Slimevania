var _direction = new Vector2(0, 0);

switch (transitionDir) {
    case "right": _direction.x = 1; break;
    case "left": _direction.x = -1; break;
    case "down": _direction.y = 1; break;
    case "up": _direction.y = -1; break;
}

// Collision Event do oTransitionLine com oPlayer
global.entranceDirection = transitionDir;
global.playerExitPosition = (transitionDir == "left" || transitionDir == "right") ? oPlayer.y : oPlayer.x;

global.roomManager.change_room(room, _direction.x, _direction.y);
