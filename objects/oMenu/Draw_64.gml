if (!is_undefined(on_draw)) {
    on_draw(self);
}

if (!is_undefined(panel_draw)) {
    panel_draw(self);
} else if (!is_undefined(default_panel_draw)) {
    default_panel_draw(self);
}
