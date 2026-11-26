// Draw GUI
var _player = oGame.deathPlayer;
if (_player != noone) {
    if (!oGame.deathFrozen) {
        // A cena deste frame foi desenhada com o jogador oculto.
        if (surface_exists(viewSurface)) {
            deathSurface = surface_create(surface_get_width(viewSurface), surface_get_height(viewSurface));
            if (surface_exists(deathSurface)) surface_copy(deathSurface, 0, 0, viewSurface);
        }
        oGame.freeze_death_scene();
    }
    draw_view(surface_exists(deathSurface) ? deathSurface : viewSurface);
    var _drawX = floor((gameSize.x - min(room_width, gameSize.x)) * .5);
    var _cameraX = _drawX > 0 ? max(0, floor(x)) : x;
    draw_sprite_ext(_player.sprite_index, floor(_player.image_index),
        _drawX + _player.x - _cameraX, _player.y - y,
        _player.image_xscale, _player.image_yscale, _player.image_angle, _player.image_blend, _player.image_alpha);
}
if (instance_exists(target)) hud.draw_hearts(target);
