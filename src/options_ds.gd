class_name Options
const DISABLED_PROPS = []
func _validate_property(property: Dictionary) -> void:
	if property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE and property.name not in DISABLED_PROPS:
		property.usage |= PROPERTY_USAGE_STORAGE
static var enable_shadows:bool = true
static var enable_bloom:bool = true
static var enable_anti_alias:bool = true

static var volume_sfx:float = 1.0
static var volume_music:float = 1.0

static var skip_intro:bool = false
static var skip_tutorial:bool = false
static var salt_physics:bool = true

static var stats:Statistics = null
