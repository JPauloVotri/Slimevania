if (drop != noone) {
	with (drop) {
		if (place_meeting(x, y + 2, oStrangeWaterSpring)) {
			y += 2;
		} else {
			droping = true;
			drop = noone;
		}
	}
}