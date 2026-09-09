#region Inputs
    keys.left = keyboard_check(vk_left) || keyboard_check(ord("A"));
    keys.right = keyboard_check(vk_right) || keyboard_check(ord("D"));
    keys.down = keyboard_check_pressed(vk_down) ||
            keyboard_check_pressed(ord("S"));
    keys.jump = keyboard_check_pressed(vk_space) ||
            keyboard_check_pressed(vk_up) ||
            keyboard_check_pressed(ord("W"));
#endregion

#region Cálculo do movimento
    var dir = keys.right - keys.left;

    velocity.x = dir * MOVEMENT_SPEED;
    velocity.y = min(velocity.y + GRAVITY, MAX_FALL_SPEED);

    if (on_solid() && velocity.y > 0) {
        var isOnOneWay = place_meeting(x, y + 1, oOneWayBlock);

        if (keys.jump) {
            collide_y();
            velocity.y = -JUMP_SPEED;
        } else if (isOnOneWay && keys.down) {
            y++;
        } else {
            collide_y();
        }
    }
#endregion

move(velocity);