mouseOver = false;

var _start = new Vector2(x + padding.left, y + padding.top);
var _end = new Vector2(_start.x + width - 1, _start.y + height - 1);

if (!is_undefined(description)) {
    _start.y += optionsSize.y;
}

if (point_in_rectangle(mouse_x, mouse_y, _start.x, _start.y, _end.x, _end.y)) {
    mouseOver = true;

    if (mousePrev.x != mouse_x || mousePrev.y != mouse_y) {
        var _mouseHover = 0;
        var _lines = isHorizontal ? 1 : optionsCount;

        if (!is_undefined(description)) {
            _lines++;
        }

        if (isHorizontal) {
            _mouseHover = (mouse_x - _start.x) div optionsSize.x;
        } else {
            _mouseHover = (mouse_y - _start.y) div optionsSize.y;
        }

        hover = clamp(_mouseHover, 0, optionsCount - 1);
    }
}

if (inputs.cancel.check_pressed() || inputs.close.check_pressed()) {
    instance_destroy();
    return;
}

hover += inputs.next.check_stutter(20, 10) - inputs.previous.check_stutter(20, 10);
hover = (hover + optionsCount) % optionsCount;

if ((mouse_check_button_pressed(mb_left) && mouseOver) || inputs.confirm.check_pressed()) {
    var _func = options[hover].action;
    if (!is_undefined(_func)) _func(self);
}

if (!is_undefined(on_step)) {
    on_step(self);
}

mousePrev.rewrite(mouse_x, mouse_y);
