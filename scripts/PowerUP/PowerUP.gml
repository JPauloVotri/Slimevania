/// Estrutura de ações relacionadas ao gameplay
function PowerUP() constructor {
    /// @desc Utiliza o powerup ativo no personagem
    /// @param {Asset.GMObject.oPlayer} _player Instância do player
    function use_power_up(_player) {
        switch (_player.activePower) {
            case "powerDash":
                _player.stateMachine.change_state(STATES.DASHING);
                // power_dash(_player);
                break;
        }
    };

    /// @desc Atualiza o powerup usado pelo player
    /// @param {Id.Instance} _power Instância do powerup
    /// @param {Asset.GMObject.oPlayer} _player Instância do player
    function set_power_up(_power, _player) {
        if (array_contains(_player.powers, _power.name)) {
            _player.activePower = _power.name;
        };
    };
