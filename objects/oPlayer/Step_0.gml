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
    var _dir = keys.right - keys.left;

    velocity.x = _dir * MOVEMENT_SPEED;
    velocity.y = min(velocity.y + GRAVITY, MAX_FALL_SPEED);

    if (on_solid() && velocity.y > 0) {
        var _isOnOneWay = place_meeting(x, y + 1, oOneWayBlock);

        if (keys.jump) {
            collide_y();
            velocity.y = -JUMP_SPEED;
        } else if (_isOnOneWay && keys.down) {
            y++;
        } else {
            collide_y();
        }
    }

    move(velocity);
#endregion

#region Movimentação da câmera
    var _view = {
        position: new Vector2(
            camera_get_view_x(view_camera[0]),
            camera_get_view_y(view_camera[0])
        ),
        size: new Vector2(
            camera_get_view_width(view_camera[0]),
            camera_get_view_height(view_camera[0])
        ),
    };

    var _goTo = new Vector2(
        x + (velocity.x * 96) - (_view.size.x * .5),
        y + (velocity.y * 24) - (_view.size.y * .5)
    );

    var _cameraPosition = new Vector2(
        lerp(_view.position.x, _goTo.x, .03),
        lerp(_view.position.y, _goTo.y, .05)
    );

    _cameraPosition.scaleRW(10);
    _cameraPosition.rndRW();
    _cameraPosition.scaleRW(.1);

    _cameraPosition.x = clamp(_cameraPosition.x, 0, room_width - _view.size.x);
    _cameraPosition.y = clamp(_cameraPosition.y, 0, room_height - _view.size.y);

    camera_set_view_pos(view_camera[0], _cameraPosition.x, _cameraPosition.y);
#endregion
