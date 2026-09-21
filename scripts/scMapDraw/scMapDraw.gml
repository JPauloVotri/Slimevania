/// Estrutura responsável por desenhar o mapa na interface.
/// @param {Struct.Map} _map O mapa que será desenhado.
/// @param {Struct.Vector2} _position A posição do mapa na interface.
/// @param {Real} _width A largura do mapa em tiles.
/// @param {Real} _height A altura do mapa em tiles.
function MapDraw(_map, _position, _width, _height) constructor {
    border = 2;
    position = _position;
    tileSize = new Vector2(16, 9);
    width = _width;
    height = _height;

    backgroundColor = #11111B;

    alpha = {
        min: .25,
        max: 1,
        transition: 64,
        speed: .15,
    };
    currentAlpha = alpha.max;
    map = _map;

    limit = {
        left: position.x - border,
        top: position.y - border,
        right: position.x + border + _width * tileSize.x,
        bottom: position.y + border + _height * tileSize.y,
    }

    /// Calcula a opacidade do mapa com base na distância até o jogador.
    /// @param {Struct.Vector2} _playerPosition A posição atual do jogador.
    /// @returns {Real} A opacidade alvo do mapa.
    calculate_target_alpha = function(_playerPosition) {
        var _closestPoint = new Vector2(
            clamp(_playerPosition.x, limit.left, limit.right),
            clamp(_playerPosition.y, limit.top, limit.bottom)
        );
        var _distance = _playerPosition
            .copy()
            .subtractRW(_closestPoint)
            .magnitude();
        var _amount = clamp(_distance / alpha.transition, 0, 1);

        return lerp(alpha.min, alpha.max, _amount);
    }

    /// Atualiza gradualmente a opacidade do mapa em direção à opacidade alvo.
    /// @param {Struct.Vector2} _playerPosition A posição atual do jogador.
    update_alpha = function(_playerPosition) {
        var _target = calculate_target_alpha(_playerPosition);
        currentAlpha = lerp(currentAlpha, _target, alpha.speed);
    }

    /// Retorna o índice do tile visual correspondente ao tile do mapa.
    /// @param {Struct.MapTile|Undefined} _tile A tile do mapa, se existir.
    /// @returns {Real} O índice do tile visual.
    get_tile_data = function(_tile) {
        if (is_undefined(_tile)) return 1;
        if (_tile.visited) return 3;
        if (!_tile.hidden) return 2;

        return 1;
    }

    /// Desenha o mapa e marca a sala atual com o indicador do jogador.
    /// @param {Struct.Vector2} _currentRoomPosition A posição da sala atual.
    draw = function(_currentRoomPosition) {
        var _initialAlpha = draw_get_alpha();
        var _initialColor = draw_get_color();
        var _frame = (current_time % 1000) > 500;

        draw_set_color(backgroundColor);
        draw_set_alpha(currentAlpha);
        draw_rectangle(
            limit.left,
            limit.top,
            limit.right - 1,
            limit.bottom - 1,
            false
        );

        var _position = new Vector2(0, 0);
        var _offset = new Vector2(width, height).scaleRW(.5).flrRW();

        draw_set_color(#FFFFFF);

        for (var _i = 0; _i < width; _i++) {
            for (var _j = 0; _j < height; _j++) {
                _position.rewrite(_i, _j);

                var _guiPos = _position.copy()
                    .componentMultiplyRW(tileSize)
                    .addRW(position);
                var _tilePos = _position.copy()
                    .addRW(_currentRoomPosition)
                    .subtractRW(_offset);
                var _tile = map.get_tile(_tilePos);
                var _tileData = get_tile_data(_tile);

                draw_tile(tsMapTiles, _tileData, 0, _guiPos.x, _guiPos.y);

                if (_tilePos.equalsRW(_currentRoomPosition)) {
                    draw_sprite(sMapPlayer, _frame, _guiPos.x, _guiPos.y);
                }
            }
        }

        draw_set_color(_initialColor);
        draw_set_alpha(_initialAlpha);
    }
}
