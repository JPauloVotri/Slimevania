if (hasImpacted || object_index != oProjectile) exit;
if (other.receive_damage(4)) on_collision(other);
