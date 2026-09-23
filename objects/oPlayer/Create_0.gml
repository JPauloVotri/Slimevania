// Herda os eventos do objeto pai
event_inherited();

GRAVITY = .15;
JUMP_SPEED = 5;
MAX_FALL_SPEED = 4;
MOVEMENT_SPEED = 2;
CLIMB_SPEED = 1.5;
SLIDE_SPEED = 1;
LEDGE_DURATION = 14; // Em frames
LEDGE_MAX_HEIGHT = 32;
LEDGE_REACH = 8;

facing = 0;
climbSide = 0;
ledgeStart = new Vector2(0, 0);
ledgeTarget = new Vector2(0, 0);
keys = { };

#region Powerups
    powersList = [];
    activePower = "";
    recharge = 0;

    // PowerDash
    DASH_DURATION = .2;
    DASH_SPEED = 8;
    DASH_RECHARGE = 2;
#endregion

#region Máquina de estados
    stateMachine = new StateMachine();

    #region Funções de controle dos States
        /** Atualiza o estado "IDLE" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var idle_update = function() {
            if (set_climbing_state()) return;

            if (!on_solid()) {
                stateMachine.change_state(STATES.ON_AIR);
                return;
            }

            if (keys.usePower && recharge <= 0 && activePower != "") {
                var _usePowers = new PowerUP();
                _usePowers.use_power_up(self.id);
                return;
            }

            var _dir = keys.right - keys.left;

            if (abs(_dir)) {
                stateMachine.change_state(STATES.WALKING);
                return;
            }

            velocity.x = 0;
            velocityReminder.x = 0;

            var _isOnOneWay = place_meeting(x, y + 1, oOneWayBlock);

            if (keys.jump) {
                velocity.y = -JUMP_SPEED;
            } else if (_isOnOneWay && keys.descend) {
                y++;
            }
        };

        /** Atualiza o estado "WALKING" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var walking_update = function() {
            if (set_climbing_state()) return;

            if (!on_solid()) {
                stateMachine.change_state(STATES.ON_AIR);
                return;
            }

            var _dir = keys.right - keys.left;

            if (keys.usePower && recharge <= 0 && activePower != "") {
                var _usePowers = new PowerUP();
                _usePowers.use_power_up(self.id);
                return;
            }

            if (!abs(_dir)) {
                stateMachine.change_state(STATES.IDLE);
                return;
            }

            velocity.x = _dir * MOVEMENT_SPEED;

            var _isOnOneWay = place_meeting(x, y + 1, oOneWayBlock);

            if (keys.jump) {
                velocity.y = -JUMP_SPEED;
            } else if (_isOnOneWay && keys.descend) {
                y++;
            }
        }

        /** Inicia o estado "ON_AIR" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var on_air_create = function() {
            onAirInitialXDirection = sign(velocity.x);
            onAirDirectionChanged = false;
        }

        /** Atualiza o estado "ON_AIR" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var on_air_update = function() {
            if (set_climbing_state()) return;

            velocity.y = min(velocity.y + GRAVITY, MAX_FALL_SPEED);

            if (on_solid() and velocity.y > 0) {
                collide_y();
                stateMachine.change_state(STATES.IDLE);
                return;
            }

            if (keys.jumpRelease && velocity.y < 0) {
                velocity.y /= 2;
                velocityReminder.y = 0;
            }

            var _dir = keys.right - keys.left;

            if (keys.usePower && recharge <= 0 && activePower != "") {
                var _usePowers = new PowerUP();
                _usePowers.use_power_up(self.id);
                return;
            }

            if (_dir != onAirInitialXDirection) {
                onAirDirectionChanged = true;
            }

            if (_dir == 0) {
                _dir = sign(velocity.x);
            }

            var _speedMultiplier = onAirDirectionChanged ? .5 : 1;
            velocity.x = _dir * MOVEMENT_SPEED * _speedMultiplier;
        }

        /** Inicia o estado "DASHING" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var dashing_create = function() {
            recharge = DASH_RECHARGE;

            var _direction = new Vector2(
                keys.right - keys.left,
                keys.down - keys.up
            );

            if (_direction.magnitude() == 0) {
                _direction.x = facing;
            }

            var _lenght = _direction.magnitude();

            velocity.rewriteRW(_direction.normalized().scaleRW(DASH_SPEED));

            handle_dash_cracked_block_collision();
        }

        /** Atualiza o estado "DASHING" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var dashing_update = function() {
            var _timeout = stateMachine.time / game_get_speed(gamespeed_fps) > DASH_DURATION;
            var _mod = stateMachine.time mod 2;

            if (_mod == 0) {
                var _trace = instance_create_layer(x, y, "Game", oTrace);

                _trace.sprite_index = sprite_index;
                _trace.image_index = image_index;
                _trace.image_xscale = image_xscale;
                _trace.image_yscale = image_yscale;
                _trace.image_angle  = image_angle;
                _trace.image_speed = 0;
                _trace.image_alpha = .6;
                _trace.depth = depth + 1;

                _trace.on_step = function(_inst) {
                    _inst.image_alpha -= .06;

                    if (_inst.image_alpha <= 0) {
                        instance_destroy(_inst, false);
                    }
                }
            }

            handle_dash_cracked_block_collision();

            if (_timeout || velocity.magnitude() <= 0) {
                stateMachine.change_state(STATES.IDLE);
            }
        }

        /** Encerra o estado "DASHING" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var dashing_destroy = function() {
            velocity.rewrite(
                min(abs(velocity.x), MOVEMENT_SPEED) * sign(velocity.x),
                clamp(velocity.y, -JUMP_SPEED / 2, MAX_FALL_SPEED)
            )
        }

        /** Inicia o estado "CLIMBING" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var climbing_create = function() {
            climbSide = get_roughcast_block_collision_side();
            facing = climbSide;
            velocity.rewrite(0, SLIDE_SPEED);
            velocityReminder.x = 0;
            velocityReminder.y = 0;
        }

        /** Atualiza o estado "CLIMBING" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var climbing_update = function() {
            if (!place_meeting(x + climbSide, y, oRoughcastBlock)) {
                if (keys.up) {
                    var _target = find_ledge_target();

                    if (_target != undefined) {
                        ledgeTarget = _target;   // define ANTES de trocar de estado
                        stateMachine.change_state(STATES.LEDGE);
                        return;
                    }
                }

                stateMachine.change_state(STATES.ON_AIR);
                return;
            }

            if (on_solid() && !keys.up) {
                stateMachine.change_state(STATES.IDLE);
                return;
            }

            var _dir = -keys.left + keys.right;

            if (_dir == -climbSide) {
                stateMachine.change_state(STATES.ON_AIR);
                return;
            }

            if (keys.usePower && recharge <= 0 && activePower != "") {
                var _usePower = new PowerUP();
                _usePower.use_power_up(self.id);
                return;
            }

            velocity.x = 0;
            velocityReminder.x = 0;
            velocity.y = keys.up ? -CLIMB_SPEED : SLIDE_SPEED;
        }

        /** Inicia o estado "LEDGE" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var ledge_create = function() {
            ledgeStart.rewrite(x, y);
            velocity.rewrite(0, 0);
            velocityReminder.rewrite(0, 0);
            facing = -climbSide;
        }

        /** Atualiza o estado "LEDGE" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var ledge_update = function() {
            var _t = clamp(stateMachine.time / LEDGE_DURATION, 0, 1);

            // Sobe nos primeiros 60% e desliza pro lado a partir dos 40%
            var _ty = clamp(_t / 0.6, 0, 1);
            var _tx = clamp((_t - 0.4) / 0.6, 0, 1);

            // easing suave (começa rápido, termina devagarinho)
            _ty = 1 - sqr(1 - _ty);
            _tx = 1 - sqr(1 - _tx);

            x = round(lerp(ledgeStart.x, ledgeTarget.x, _tx));
            y = round(lerp(ledgeStart.y, ledgeTarget.y, _ty));

            if (_t >= 1) {
                stateMachine.change_state(STATES.IDLE);
            }
        }

        /** Encerra o estado "LEDGE" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var ledge_destroy = function() {
            velocity.rewrite(0, 0);
            velocityReminder.rewrite(0, 0);
        }

        /** Atualiza o estado "CUTSCENE" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var cutscene_update = function() {
            velocity.x = 0;
            velocityReminder.x = 0;

            // Se pegou o trigger no ar, deixa cair até o chão antes de ficar parado
            if (on_solid() && velocity.y >= 0) {
                velocity.y = 0;
                velocityReminder.y = 0;
            } else {
                velocity.y = min(velocity.y + GRAVITY, MAX_FALL_SPEED);
            }
        };
    #endregion

    var idleState = new State(STATES.IDLE)
        .set_update(idle_update);

    var walkingState = new State(STATES.WALKING)
        .set_update(walking_update);

    var onAirState = new State(STATES.ON_AIR)
        .set_create(on_air_create)
        .set_update(on_air_update);

    var dashingState = new State(STATES.DASHING)
        .set_create(dashing_create)
        .set_update(dashing_update)
        .set_destroy(dashing_destroy);

    var climbingState = new State(STATES.CLIMBING)
        .set_create(climbing_create)
        .set_update(climbing_update);

    var ledgeState = new State(STATES.LEDGE)
        .set_create(ledge_create)
        .set_update(ledge_update)
        .set_destroy(ledge_destroy);

    var cutsceneState = new State(STATES.CUTSCENE)
        .set_update(cutscene_update);

    stateMachine
        .add_state(idleState)
        .add_state(walkingState)
        .add_state(onAirState)
        .add_state(dashingState)
        .add_state(climbingState)
        .add_state(ledgeState)
        .add_state(cutsceneState);
#endregion

#region Funções do player
    /// Destrói blocos quebráveis atingidos durante o dash.
    function handle_dash_cracked_block_collision() {
        var _crackedBlock = instance_place(
            x + velocity.x,
            y + velocity.y,
            oCrackedBlock
        );

        if (_crackedBlock) {
            oGame.roomManager.destroy_instance_and_persist(_crackedBlock);
        }
    }

    /// Coleta o power-up encontrado pelo jogador.
    function handle_power_up_pickup() {
        /// @type {Id.Instance.oPowerUp}
        var _powerUp = instance_place(x, y, oPowerUp);

        if (!_powerUp) {
            return;
        }

        if (!array_contains(powersList, _powerUp.name)) {
            array_push(powersList, _powerUp.name);
            activePower = _powerUp.name;
        }

        oGame.roomManager.destroy_instance_and_persist(_powerUp);
    }

    /// Procura um ponto onde o jogador cabe em cima da borda.
    /// @returns {Struct.Vector2, Undefined}
    function find_ledge_target() {
        var _tx = x + climbSide * LEDGE_REACH;

        for (var _up = 0; _up <= LEDGE_MAX_HEIGHT; _up++) {
            var _ty = y - _up;

            if (!place_meeting(_tx, _ty, oBlock) &&
                place_meeting(_tx, _ty + 1, oBlock)) {
                return new Vector2(_tx, _ty);
            }
        }

        return undefined;
    }

    /// Checa se há colisão com um bloco escalável, retornando o lado da colisão
    function get_roughcast_block_collision_side() {
        if (place_meeting(x + 1, y, oRoughcastBlock)) return 1;
        if (place_meeting(x - 1, y, oRoughcastBlock)) return -1;
        return 0;
    }

    /// Entra em CLIMBING se estiver colidindo com um bloco escalável
    function set_climbing_state() {
        var _side = get_roughcast_block_collision_side();
        if (_side == 0) return false;

        var _dir = keys.right - keys.left

        if (_dir == -_side) return false;

        if (on_solid() && !keys.up) return false;

        stateMachine.change_state(STATES.CLIMBING);
        return true;
    }

    /// Congela o jogador para uma cena.
    function start_cutscene() {
        stateMachine.change_state(STATES.CUTSCENE);
    }

    /// Devolve o controle ao jogador.
    function end_cutscene() {
        stateMachine.change_state(STATES.IDLE);
    }

    /// @returns {Bool}
    function in_cutscene() {
        return stateMachine.state.name == STATES.CUTSCENE;
    }
#endregion
