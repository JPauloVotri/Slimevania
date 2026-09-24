#region Inicialização
    velocity = new Vector2(0, 0);
    velocityReminder = new Vector2(0, 0);
#endregion

#region Utilitários
    /// Ação padrão de colisão no eixo X. Zera valores de velocidade.
    function collide_x() {
        velocity.x = 0;
        velocityReminder.x = 0;
    }

    /// Ação padrão de colisão no eixo Y. Zera valores de velocidade.
    function collide_y() {
        velocity.y = 0;
        velocityReminder.y = 0;
    }

    /// Verifica se o ator está em cima de um objeto sólido.
    /// @returns {Bool} Retorna true se o ator estiver em cima de um objeto sólido, caso contrário retorna false.
    function on_solid() {
        return place_meeting(x, y + 1, oBlock) ||
            place_meeting(x, y + 1, oOneWayBlock) &&
            !place_meeting(x, y, oOneWayBlock) ||
            check_room_limits_collision(0, 1);
    }
#endregion

#region Movimento e colisão
    /// Movimenta o ator com precisão de pixel, considerando colisões com objetos sólidos.
    /// @param {Struct.Vector2} _velocity Velocidade do movimento.
    /// @param {Function} _x_collision_event Função a ser chamada quando houver colisão no eixo X. Recebe como parâmetro a instância do objeto sólido com o qual houve a colisão.
    /// @param {Function} _y_collision_event Função a ser chamada quando houver colisão no eixo Y. Recebe como parâmetro a instância do objeto sólido com o qual houve a colisão.
    function move(
        _velocity,
        _x_collision_event = function(_instance) { collide_x(); },
        _y_collision_event = function(_instance) { collide_y(); }
    ) {
        velocityReminder.addRW(_velocity);
        var _move = velocityReminder.abs();
        _move.flrRW();
        _move.componentMultiplyRW(velocityReminder.sign());

        // Movimento no eixo X
        if (_move.x != 0) {
            velocityReminder.x -= _move.x;
            var _dir = sign(_move.x);

            while (_move.x != 0) {
                var _collision_instance = instance_place(x + _dir, y, oBlock);

                if (_collision_instance != noone) {
                    _collision_instance = instance_place(x + _dir, y - 1, oBlock);

                    if (_collision_instance == noone && on_solid()) {
                        x += _dir;
                        y--;
                        _move.x -= _dir;

                        if (abs(_move.x) >= 1) {
                            _move.x -= _dir;
                        } else {
                            velocityReminder.x -= _dir;
                        }

                        continue;
                    }
                    _x_collision_event(_collision_instance);
                    break;
                }

                if (check_room_limits_collision(_dir, 0)) {
                    _x_collision_event(noone);
                    break;
                }

                x += _dir;
                _move.x -= _dir;

                _collision_instance = instance_place(x, y + 1, oBlock);
                if (_collision_instance == noone) {
                    _collision_instance = instance_place(x - _dir, y + 1, oBlock);

                    if (_collision_instance != noone) {
                        y++;
                    }
                }
            }
        }

        // Movimento no eixo Y
        if (_move.y != 0) {
            velocityReminder.y -= _move.y;
            var _dir = sign(_move.y);

            while (_move.y != 0) {
                var _collision_instance = instance_place(x, y + _dir, oBlock);

                if (_collision_instance != noone) {
                    _y_collision_event(_collision_instance);
                    break;
                }

                // Colisão com sólidos de apenas uma direção
                _collision_instance = instance_place(x, y + _dir, oOneWayBlock);
                if (_collision_instance != noone &&
                    bbox_bottom <= _collision_instance.bbox_top) {
                    _y_collision_event(_collision_instance);
                    break;
                }

                if (check_room_limits_collision(0, _dir)) {
                    _y_collision_event(noone);
                    break;
                }

                y += _dir;
                _move.y -= _dir;
            }
        }
    }

    /// Verifica se a próxima posição do ator ultrapassa os limites da sala atual.
    /// Quando a sala não tem vizinho em determinada direção, a borda da room passa a
    /// funcionar como barreira de colisão e a função retorna `true`.
    /// @param {Real} _dx Deslocamento proposto no eixo horizontal.
    /// @param {Real} _dy Deslocamento proposto no eixo vertical.
    /// @returns {Bool} Se a colisão com os limites da sala ocorrer.
    check_room_limits_collision = function(_dx, _dy) {
        if (!instance_exists(oGame)) return false;
        if (is_undefined(oGame.roomManager)) return false;

        var _hasNeighbor = oGame.roomManager.hasNeighbor;

        if (!_hasNeighbor.left && bbox_left + _dx < 0) return true;
        if (!_hasNeighbor.right && bbox_right + _dx >= room_width) return true;
        if (!_hasNeighbor.top && bbox_top + _dy < 0) return true;
        if (!_hasNeighbor.bottom && bbox_bottom + _dy >= room_height) return true;

        return false;
    }
#endregion
