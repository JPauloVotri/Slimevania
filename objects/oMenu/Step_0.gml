mouseOver = false;

if (!is_undefined(on_step)) {
    on_step(self);
}

mousePrev.rewrite(mouse_x, mouse_y);
