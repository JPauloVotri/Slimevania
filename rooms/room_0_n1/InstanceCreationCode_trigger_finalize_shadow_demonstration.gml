object = oShadow;

on_trigger = function(_instance) {
	with (oTrigger) {
		oGame.roomManager.destroy_instance_and_persist(self);
	}
	
	with (oShadow) {
		oGame.roomManager.destroy_instance_and_persist(self);
	}
};