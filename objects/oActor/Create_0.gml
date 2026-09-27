#region Inicialização
    velocity = new Vector2(0, 0);
    velocityReminder = new Vector2(0, 0);
    ignoreSlopeDown = false;
    ignoreSlopeUp = false;
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
    /// @param {[Function]} _x_collision_event Função a ser chamada quando houver colisão no eixo X. Recebe como parâmetro a instância do objeto sólido com o qual houve a colisão.
    /// @param {[Function]} _y_collision_event Função a ser chamada quando houver colisão no eixo Y. Recebe como parâmetro a instância do objeto sólido com o qual houve a colisão.
    function move(
        _velocity,
        _x_collision_event = function(_instance) { collide_x(); },
        _y_collision_event = function(_instance) { collide_y(); }
    ) {
        velocityReminder.addRW(_velocity);

        var _move = velocityReminder.abs().flrRW()
            .componentMultiplyRW(velocityReminder.sign());

        if (_move.x != 0) {
            __move_x(_move.x, _x_collision_event);
        }

        if (_move.y != 0) {
            __move_y(_move.y, _y_collision_event);
        }
    }

    /// Move o ator no eixo X, pixel a pixel, tratando colisões e step-up.
    /// @param {Real} _amount Quantidade a mover no eixo X.
    /// @param {Function} _on_collision Callback ao colidir.
    __move_x = function(_amount, _on_collision) {
        var _dir = sign(_amount);

        velocityReminder.x -= _amount;

        while (_amount != 0) {
            var _collisionInstance = instance_place(x + _dir, y, oBlock);

            if (_collisionInstance != noone) {
                if (!ignoreSlopeUp && try_step_up(_dir)) {
                    _amount -= _dir;

                    if (abs(_amount) >= 1) {
                        _amount -= _dir;
                    } else {
                        velocityReminder.x -= _dir;
                    }

                    continue;
                }

                _on_collision(_collisionInstance);
                break;
            }

            if (check_room_limits_collision(_dir, 0)) {
                _on_collision(noone);
                break;
            }

            x += _dir;
            _amount -= _dir;

            if (!ignoreSlopeDown) {
                try_step_down(_dir);
            }
        }
    }

    /// Move o ator no eixo Y, pixel a pixel, tratando colisões e blocos unidirecionais.
    /// @param {Real} _amount Quantidade a mover no eixo Y.
    /// @param {Function} _on_collision Callback ao colidir.
    __move_y = function(_amount, _on_collision) {
        var _dir = sign(_amount);
        velocityReminder.y -= _amount;

        while (_amount != 0) {
            var _collisionInstance = instance_place(x, y + _dir, oBlock);

            if (_collisionInstance != noone) {
                _on_collision(_collisionInstance);
                break;
            }

            // Colisão com sólidos de apenas uma direção
            _collisionInstance = instance_place(x, y + _dir, oOneWayBlock);
            if (_collisionInstance != noone && bbox_bottom <= _collisionInstance.bbox_top) {
                _on_collision(_collisionInstance);
                break;
            }

            if (check_room_limits_collision(0, _dir)) {
                _on_collision(noone);
                break;
            }

            y += _dir;
            _amount -= _dir;
        }
    }

    /// Tenta subir um degrau quando há um bloco à frente e espaço livre acima.
    /// @param {Real} _dir Direção do movimento.
    /// @returns {Bool} True se conseguiu subir.
    try_step_up = function(_dir) {
        var _above = instance_place(x + _dir, y - 1, oBlock);

        if (_above != noone) return false;
        if (!on_solid()) return false;

        x += _dir;
        y--;

        return true;
    }

    /// Tenta descer um degrau quando há espaço livre abaixo e um bloco antes.
    /// @param {Real} _dir Direção do movimento.
    try_step_down = function(_dir) {
        // Tem bloco 1px abaixo?
        if (instance_place(x, y + 1, oBlock) != noone) return;

        // Não tem bloco 2px abaixo? (Não configura mais uma rampa)
        if (instance_place(x, y + 2, oBlock) == noone) return;

        // Não está vindo de um chão válido? (Não está caminhando)
        if (instance_place(x - _dir, y + 1, oBlock) == noone) return;

        y++;
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
