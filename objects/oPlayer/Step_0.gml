#region Inputs
    keys.left = keyboard_check(vk_left) || keyboard_check(ord("A"));
    keys.right = keyboard_check(vk_right) || keyboard_check(ord("D"));
    keys.up = keyboard_check(vk_up) || keyboard_check(ord("W"));
    keys.down = keyboard_check(vk_down) || keyboard_check(ord("S"));
    keys.descend = keyboard_check_pressed(vk_down) ||
            keyboard_check_pressed(ord("S"));
    keys.jump = keyboard_check_pressed(vk_space);
    keys.jumpRelease = keyboard_check_released(vk_space);
    keys.usePower = keyboard_check_pressed(vk_shift);
#endregion

// TODO: Encontrar um lugar melhor para isso
var _dir = keys.right - keys.left;
if (_dir != 0) { facing_x = _dir };
if (recharge > 0) {
    recharge -= delta_time / 1000000;
    if (recharge <= 0) {
        recharge = 0;
    }
};

#region Máquina de estados e movimento
    stateMachine.update();
    move(velocity);
#endregion
