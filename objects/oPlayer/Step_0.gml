#region Inputs
    var _keys = oGame.inputKeys;

    keys.left = _keys.left.check();
    keys.right = _keys.right.check();
    keys.up = _keys.up.check();
    keys.down = _keys.down.check();
    keys.descend = _keys.down.check_pressed(true);
    keys.jump = _keys.pad1.check_pressed(true);
    keys.jumpRelease = _keys.pad1.check_released(true);
    keys.usePower = _keys.pad3.check_pressed();
#endregion

if (in_cutscene()) {
    keys.left = 0;
    keys.right = 0;
    keys.up = 0;
    keys.down = 0;
    keys.descend = 0;
    keys.jump = 0;
    keys.jumpRelease = 0;
    keys.usePower = 0;
}

// TODO: Encontrar um lugar melhor para isso
var _dir = keys.right - keys.left;
if (_dir != 0) {
    facing = _dir;
}
if (recharge > 0) {
    recharge -= delta_time / 1000000;
    if (recharge <= 0) {
        recharge = 0;
    }
}
handle_power_up_pickup();

#region Máquina de estados e movimento
    stateMachine.update();
    move(velocity);
#endregion
