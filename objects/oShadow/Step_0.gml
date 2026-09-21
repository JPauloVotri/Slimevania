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

#region Máquina de estados e movimento
    stateMachine.update();
    move(velocity);
#endregion
