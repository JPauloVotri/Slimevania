// Room Start Event do oController
if (variable_global_exists("entranceDirection") && global.entranceDirection != undefined) {

    // qual borda a gente precisa (baseado na direção de entrada)
    var _requiredBorder = "";
    switch (global.entranceDirection) {
        case "right":
            _requiredBorder = "left";
            break;
        case "left":
            _requiredBorder = "right";
            break;
        case "down":
            _requiredBorder = "top";
            break;
        case "up":
            _requiredBorder = "bottom";
            break;
    }

    var _totalSpawns = instance_number(oSpawn);
    var _foundedSpawn = noone;
    var _minDifference = infinity;
    var _verticalAxis = (_requiredBorder == "top" || _requiredBorder == "bottom");

    for (var _i = 0; _i < _totalSpawns; _i++) {
        var _spawn = instance_find(oSpawn, _i);

        // calcula a distância desse spawn até cada borda da room
        var _distLeft = _spawn.x;
        var _distRight = room_width - _spawn.x;
        var _distTop = _spawn.y;
        var _distBottom = room_height - _spawn.y;

        // descobre qual borda esse spawn "pertence" (a mais próxima dele)
        var _shortestDistance = min(_distLeft, _distRight, _distTop, _distBottom);
        var _spawnBorder = "";

        if (_shortestDistance == _distLeft) _spawnBorder = "left";
        else if (_shortestDistance == _distRight) _spawnBorder = "right";
        else if (_shortestDistance == _distTop) _spawnBorder = "top";
        else _spawnBorder = "bottom";

        // só considera se for da borda certa
        if (_spawnBorder == _requiredBorder) {
            var _difference = _verticalAxis ? abs(_spawn.x - global.playerExitPosition) : abs(_spawn.y - global.playerExitPosition);

            if (_difference < _minDifference) {
                _minDifference = _difference;
                _foundedSpawn = _spawn;
            }
        }
    }

    if (_foundedSpawn != noone) {
        oPlayer.x = _foundedSpawn.x;
        oPlayer.y = _foundedSpawn.y;
    } else {
        show_debug_message("Nenhum oSpawn encontrado para direção: " + global.entranceDirection);
    }

    global.entranceDirection = undefined;
}
