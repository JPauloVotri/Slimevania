var _powerName = other.nome;

array_push(powersList, _powerName);

if (activePower == "") { activePower = _powerName };

array_push(global.powerups, _powerName);

instance_destroy(other);