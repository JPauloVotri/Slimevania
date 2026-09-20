if (instance_number(oGame) > 1) {
    instance_destroy();
    return;
}

roomManager = new RoomManager();
