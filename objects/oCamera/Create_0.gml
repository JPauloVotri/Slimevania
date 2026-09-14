gameSize = new Vector2(
    camera_get_view_width(view_camera[0]),
    camera_get_view_height(view_camera[0])
);
viewSurface = -1;
target = oPlayer;
goTo = new Vector2(x, y);

x = oPlayer.x - gameSize.x * .5;
y = oPlayer.y - gameSize.y * .5;

application_surface_enable(false);
camera_set_view_size(view_camera[0], gameSize.x + 1, gameSize.y + 1);
display_set_gui_size(gameSize.x, gameSize.y);
