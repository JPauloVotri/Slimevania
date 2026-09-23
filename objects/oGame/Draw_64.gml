if (isPaused) {
    menuMapDraw.draw(roomManager.get_current_room_position(), menuMapCenter);
    return;
}

miniMapDraw.draw(roomManager.get_current_room_position());
