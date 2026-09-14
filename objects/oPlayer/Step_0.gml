#region Inputs
    keys.left = keyboard_check(vk_left) || keyboard_check(ord("A"));
    keys.right = keyboard_check(vk_right) || keyboard_check(ord("D"));
    keys.down = keyboard_check_pressed(vk_down) ||
        keyboard_check_pressed(ord("S"));
    keys.jump = keyboard_check_pressed(vk_space) ||
        keyboard_check_pressed(vk_up) ||
        keyboard_check_pressed(ord("W"));
    keys.jumpRelease = keyboard_check_released(vk_space) ||
        keyboard_check_released(vk_up) ||
        keyboard_check_released(ord("W"));
#endregion

#region Máquina de estados e movimento
    stateMachine.update();
    move(velocity);
#endregion
