var _instance = instance_place(x, y, object);

if (_instance != noone && !triggered) {
	on_trigger(_instance);
	triggered = oneShot;
}