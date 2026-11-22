object = oShadow;

on_trigger = function(_instance) {
	orquestrador = instance_find(oCutscene, 0);
	
	if (instance_exists(orquestrador)) {
		orquestrador.destroyActor();
		
		oGame.roomManager.destroy_instance_and_persist(orquestrador);
	}
	
    with (oTrigger) {
        oGame.roomManager.destroy_instance_and_persist(self);
    }

    instance_find(oPlayer, 0).end_cutscene();
};
