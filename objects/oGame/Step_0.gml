#macro KEY_STUTTER_DELAY 20
#macro KEY_STUTTER_INTERVAL 10

if (inputKeys.start.check_pressed()) {
    isPaused = !isPaused;

    if (isPaused) {
        instance_deactivate_all(true);
        audio_pause_all();
        menuMapCenter.rewriteRW(roomManager.get_current_room_position());
    } else {
        instance_activate_all();
        audio_resume_all();
    }
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
