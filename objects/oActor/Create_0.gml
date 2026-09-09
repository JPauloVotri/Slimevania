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
            !place_meeting(x, y, oOneWayBlock);
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

                y += _dir;
                _move.y -= _dir;
            }
        }
    }
#endregion
