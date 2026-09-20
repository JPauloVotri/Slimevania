// Herda os eventos do objeto pai
event_inherited();

GRAVITY = .15;
JUMP_SPEED = 5;
MAX_FALL_SPEED = 4;
MOVEMENT_SPEED = 2;

facing = 0;
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
    enum STATES {
        IDLE,
        WALKING,
        ON_AIR,
        DASHING,
    }

    stateMachine = new StateMachine();

    #region Funções de controle dos States
        /** Atualiza o estado "IDLE" do jogador
         * @self Asset.GMObject.oPlayer
         */
        var idle_update = function() {
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

    stateMachine
        .add_state(idleState)
        .add_state(walkingState)
        .add_state(onAirState)
        .add_state(dashingState);
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
#endregion
