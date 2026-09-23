object = oShadow;

on_trigger = function(_instance) {
    var _shadow = instance_find(oShadow, 0);

    _shadow.MOVEMENT_SPEED = 0;

    var _ts = time_source_create(
        time_source_game, .5, time_source_units_seconds,
        function(_s) {
            if (instance_exists(_s)) _s.keys.usePower = 1;
        },
        [_shadow]
    );
    time_source_start(_ts);
};
