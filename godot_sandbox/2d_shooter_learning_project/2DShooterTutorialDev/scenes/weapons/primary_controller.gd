extends Node2D


@onready var timer_recharge_cadence: Timer = Globals.utl.timer(self)
@onready var timer_cooldown: Timer = Globals.utl.timer(self)


func _ready():
	timer_cooldown.timeout.connect(_timer_end_cooldown)
	if Globals.primary_on_cooldown:
		timer_cooldown.start(Globals.primary_ammo_recharge_delay)
	start_recharge_timer()


func _timer_end_cooldown():
	Globals.primary_on_cooldown = false
	Globals.primary_ammo_current = Globals.primary_ammo_capacity


func start_recharge_timer():
	timer_recharge_cadence.start(Globals.primary_ammo_recharge_cadence)
	await timer_recharge_cadence.timeout
	if not Globals.primary_on_cooldown:
		if Globals.primary_ammo_current < Globals.primary_ammo_capacity:
			Globals.primary_ammo_current += 1
	start_recharge_timer()


func validate_can_fire() -> bool:
	if Globals.primary_ammo_current > 0:
		Globals.primary_ammo_current -= 1
		if Globals.primary_ammo_current <= 0:
			Globals.primary_ammo_current = 0
			Globals.primary_on_cooldown = true
			timer_cooldown.start(Globals.primary_ammo_recharge_delay)
		return true
	return false

