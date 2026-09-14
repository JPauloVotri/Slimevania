camera_set_view_pos(view_camera[0], floor(x), floor(y));

if (!surface_exists(viewSurface)) {
    viewSurface = surface_create(gameSize.x + 1, gameSize.y + 1);
}

view_surface_id[0] = viewSurface;
