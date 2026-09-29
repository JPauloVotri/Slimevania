if (isPaused) {
	if (surface_exists(pauseBackground)) {
		draw_surface(pauseBackground, 0, 0);
	}
	
	draw_set_alpha(.5);
	draw_set_colour(c_black);
	draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
	draw_set_alpha(1);
	
    menuMapDraw.draw(roomManager.get_current_room_position(), menuMapCenter);
    return;
}

miniMapDraw.draw(roomManager.get_current_room_position());
