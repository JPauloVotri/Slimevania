/// Desenha o HUD do jogo.
function HudManager() constructor {
    sprite = sHeart;
    spacing = 3;
    margin = 16;

    var _w = sprite_get_width(sprite);
    var _h = sprite_get_height(sprite);
    var _lw = floor(_w / 2);   // metade esquerda
    var _rw = _w - _lw;        // metade direita (fica com o pixel que sobra)
    var _th = ceil(_h / 2);    // metade de cima (fica com o pixel que sobra)
    var _bh = _h - _th;        // metade de baixo

    // Ordem em que os quartos escurecem: [x, y, largura, altura]
    pieces = [
        [_lw, 0,   _rw, _th], // superior direita
        [_lw, _th, _rw, _bh], // inferior direita
        [0,   _th, _lw, _bh], // inferior esquerda
		[0,   0,   _lw, _th], // superior esquerda
    ];

    // 1 ponto de vida = 1 quarto de coração
    lifePerHeart = array_length(pieces);

    /// @param {Id.Instance.oPlayer} _actor Ator dono da vida.
    static draw_hearts = function(_actor) {
        var _life = _actor.actorManager.getHealth();
        var _maxLife = _life + _actor.hits;
        var _hearts = ceil(_maxLife / lifePerHeart);

        var _heartW = sprite_get_width(sprite);
        var _containerW = _hearts * _heartW + (_hearts - 1) * spacing;
        var _startX = display_get_gui_width() - _containerW - margin;

        for (var _i = 0; _i < _hearts; _i++) {
            var _x = _startX + _i * (_heartW + spacing);

            // Quartos acesos neste coração (0 a 4)
            var _lit = clamp(_life - _i * lifePerHeart, 0, lifePerHeart);
            var _dark = lifePerHeart - _lit;

            if (_dark == 0) {
                draw_sprite(sprite, 0, _x, margin);
            } else if (_lit == 0) {
                draw_sprite_ext(sprite, 0, _x, margin, 1, 1, 0, c_dkgray, 1);
            } else {
                for (var _q = 0; _q < lifePerHeart; _q++) {
                    var _p = pieces[_q];
                    var _color = (_q < _dark) ? c_dkgray : c_white;

                    draw_sprite_part_ext(
                        sprite, 0,
                        _p[0], _p[1], _p[2], _p[3],
                        _x + _p[0], margin + _p[1],
                        1, 1, _color, 1
                    );
                }
            }
        }
    }
}