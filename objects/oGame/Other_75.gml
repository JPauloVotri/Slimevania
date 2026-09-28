var _event_type = async_load[? "event_type"];

switch (_event_type) {
    case "gamepad discovered":
        var _pad = async_load[? "pad_index"];
        inputManager.gamepad = _pad;

        if (!array_contains(gamepads, _pad)) {
            array_push(gamepads, _pad);
        }
        break;

    case "gamepad lost":
        var _pad = async_load[? "pad_index"];
        var _idx = array_get_index(gamepads, _pad);

        if (_idx >= 0) {
            array_delete(gamepads, _idx, 1);

            if (array_length(gamepads) > 0) {
                inputManager.gamepad = array_last(gamepads);
            }
        }
        break;
}
