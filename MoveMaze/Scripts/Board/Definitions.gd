extends Object

class PathData:

	enum {
		INDEX = 0
		CONNECTIONS = 1,
		MOVEABLE = 2,
		COLLECTABLE = 3
	}

	const DIRECTION = {
				'N' : Vector2(0, -1),
				'E' : Vector2(1, 0),
				'S' : Vector2(0, 1),
				'W' : Vector2(-1, 0),
	}


class Options:
	const DEBUG_MAP = true
	const DISABLE_INJECTION = false
