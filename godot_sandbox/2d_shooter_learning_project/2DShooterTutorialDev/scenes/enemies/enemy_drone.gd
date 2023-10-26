extends CharacterBody2D


var is_enemy: bool = true
var health: int = 100

func projectile_hit(damage: int):
	health = health - damage
	if health <= 0:
		print("%s health = 0, destroying" % self)
		self.queue_free()
