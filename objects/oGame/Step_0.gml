#region Transição de salas pela posição do Player
    if (instance_exists(oPlayer)) {
        var _transitionDir = new Vector2(
            (oPlayer.x >= room_width) - (oPlayer.x < 0),
            (oPlayer.y >= room_height) - (oPlayer.y < 0)
        );

        roomManager.change_room(_transitionDir);
    }
#endregion
