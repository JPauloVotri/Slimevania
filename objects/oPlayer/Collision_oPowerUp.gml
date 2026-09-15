var _powerName = other.name;

array_push(powersList, _powerName);

if (activePower == "") {
    activePower = _powerName;
}

array_push(global.powerUps, _powerName);

instance_destroy(other);
