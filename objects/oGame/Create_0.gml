// Inicializa Viewports
resolution = new Vector2(1366, 768);

view_enabled = true;

view_visible[0] = true;
view_xport[0] = 0;
view_yport[0] = 0;
view_wport[0] = 512;
view_hport[0] = 288;
view_camera[0] = camera_create_view(0, 0, view_wport[0], view_hport[0], 0,
        noone, -1, -1, -1, -1);

var _displayWidth = display_get_width();
var _displayHeight = display_get_height();
var _displayX = (_displayWidth - view_wport[0]) / 2;
var _displayY = (_displayHeight - view_hport[0]) / 2;

window_set_rectangle(_displayX, _displayY, resolution.x, resolution.y);
surface_resize(application_surface, resolution.x, resolution.y);
