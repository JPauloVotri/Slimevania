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
