
class_name BossDatabase
extends RefCounted

# SPACE VAULT - SCIENTIST BOSS DATABASE
# Godot 4.7

const BOSS_ORDER: Array[String] = [
	"niq",
	"gabby",
	"ahmed",
    "celine"
]

const BOSSES: Dictionary = {
	"niq": {
		"name": "DR. NIQ",
		"number": 1,
		"attack": "SOLAR ECLIPSE SHADOW",
		"challenge": "Survive a 35-minute eclipse.",
		"debuff": "Solar generation disabled.",
		"colour": Color("#6994d6")
	},

	"gabby": {
		"name": "DR. GABBY",
		"number": 2,
		"attack": "GRAVITY WELL CRUSH",
		"challenge": "Pass the launch feasibility check.",
		"debuff": "Extra 50 kg payload mass.",
		"colour": Color("#d99b56")
	},

	"ahmed": {
		"name": "DR. AHMED",
		"number": 3,
		"attack": "SIGNAL JAMMER",
		"challenge": "Transmit enough science data.",
		"debuff": "Ground contact reduced to 3 minutes.",
		"colour": Color("#a987db")
	},

	"celine": {
		"name": "DR. CELINE",
		"number": 4,
		"attack": "ESCAPE VELOCITY CRISIS",
		"challenge": "Pass all final engineering checks.",
		"debuff": "Combined power, mass and communication tests.",
		"colour": Color("#da7587")
	}
}


static func get_boss(boss_id: String) -> Dictionary:
	if BOSSES.has(boss_id):
		return BOSSES[boss_id].duplicate(true)

	push_warning(
		"Unknown boss ID: " + boss_id
	)
	return {}


static func get_order() -> Array[String]:
	return BOSS_ORDER.duplicate()
