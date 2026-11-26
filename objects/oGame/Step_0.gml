#macro KEY_STUTTER_DELAY 20
#macro KEY_STUTTER_INTERVAL 10

if (deathPlayer != noone) {
    // Na própria sala inicial, espera a reativação sem depender de um Room Start.
    if (respawnPending && room == room_0_0) finish_respawn();
    exit;
}

if (inputKeys.start.check_pressed() && !isPaused) {
    toggle_pause_game();
}

if (isPaused) {
    var _map = roomManager.map;
    var _dir = new Vector2(
        inputKeys.right.check_stutter(KEY_STUTTER_DELAY, KEY_STUTTER_INTERVAL) -
        inputKeys.left.check_stutter(KEY_STUTTER_DELAY, KEY_STUTTER_INTERVAL),
        inputKeys.down.check_stutter(KEY_STUTTER_DELAY, KEY_STUTTER_INTERVAL) -
        inputKeys.up.check_stutter(KEY_STUTTER_DELAY, KEY_STUTTER_INTERVAL)
    );

    menuMapCenter.addRW(_dir);
    menuMapCenter = menuMapDraw.clamp_center(menuMapCenter);

    return;
}

#region Transição de salas pela posição do Player
    if (instance_exists(oPlayer)) {
        var _dir = get_transition_direction(oPlayer.x, oPlayer.y);

        roomManager.change_room(_dir);
        miniMapDraw.update_alpha(new Vector2(oPlayer.x, oPlayer.y));
    }
#endregion
