// Room Start Event do oController
if (variable_global_exists("direction_entrada") && global.direction_entrada != undefined) {
    
    // qual borda a gente precisa (baseado na direção de entrada)
    var _borda_necessaria = "";
    switch (global.direction_entrada) {
        case "right": _borda_necessaria = "left";   break;
        case "left":  _borda_necessaria = "right";  break;
        case "down":  _borda_necessaria = "top";    break;
        case "up":    _borda_necessaria = "bottom"; break;
    }
    
    var _total_spawns = instance_number(oSpawn);
    var _spawn_encontrado = noone;
    var _menor_diferenca = infinity;
    var _eixo_vertical = (_borda_necessaria == "top" || _borda_necessaria == "bottom");
    
    for (var _i = 0; _i < _total_spawns; _i++) {
        var _spawn = instance_find(oSpawn, _i);
        
        // calcula a distância desse spawn até cada borda da room
        var _dist_left   = _spawn.x;
        var _dist_right  = room_width - _spawn.x;
        var _dist_top    = _spawn.y;
        var _dist_bottom = room_height - _spawn.y;
        
        // descobre qual borda esse spawn "pertence" (a mais próxima dele)
        var _menor_dist = min(_dist_left, _dist_right, _dist_top, _dist_bottom);
        var _borda_do_spawn = "";
        
        if (_menor_dist == _dist_left) _borda_do_spawn = "left";
        else if (_menor_dist == _dist_right) _borda_do_spawn = "right";
        else if (_menor_dist == _dist_top) _borda_do_spawn = "top";
        else _borda_do_spawn = "bottom";
        
        // só considera se for da borda certa
        if (_borda_do_spawn == _borda_necessaria) {
            var _diferenca = _eixo_vertical ? abs(_spawn.x - global.player_pos_saida) : abs(_spawn.y - global.player_pos_saida);
            
            if (_diferenca < _menor_diferenca) {
                _menor_diferenca = _diferenca;
                _spawn_encontrado = _spawn;
            }
        }
    }
    
    if (_spawn_encontrado != noone) {
        oPlayer.x = _spawn_encontrado.x;
        oPlayer.y = _spawn_encontrado.y;
    } else {
        show_debug_message("Nenhum oSpawn encontrado para direção: " + global.direction_entrada);
    }
    
    global.direction_entrada = undefined;
}