triggered = false;
oneShot = true;
activated = true;
object = noone;

on_trigger = function(_instance) {
    show_error($"on_trigger não implementado em {object_get_name(object_index)}", true);
};
