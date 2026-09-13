/// Estrutura de ações relacionadas ao gameplay
function PowerUP() constructor {
	/// @desc Utiliza o powerup ativo no personagem
	/// @param {Id.Instance} _player Instância do player
	function use_power_up(_player) {
		switch (_player.activePower) {
			case "powerDash":
				power_dash(_player);
				break;
		}
	};
	
	/// @desc Atualiza o powerup usado pelo player
	/// @param {Id.Instance} _power Instância do powerup
	/// @param {Id.Instance} _player Instância do player
	function set_power_up(_power, _player) {
		if (array_contains(_player.powers, _power.name)) {
			_player.activePower = _power.name;
		};
	};
	
	function power_dash(_player) {
		if (_player.dashing) return;
		
		_player.dashing = true;
		_player.dash_timer = _player.dash_duration;
		_player.recharge = _player.dash_recharge;
		
		var _dx = keyboard_check(ord("D")) - keyboard_check(ord("A"));
		var _dy = keyboard_check(ord("S")) - keyboard_check(ord("W"));
		
		if (_dx == 0 && _dy == 0) {
			_dx = _player.facing_x;
			_dy = 0;
		};
		
		var _len = sqrt(_dx * _dx + _dy * _dy);
		
		_player.velocity.x = (_dx / _len) * _player.dash_speed;
		_player.velocity.y = (_dy / _len) * _player.dash_speed;
	};
}