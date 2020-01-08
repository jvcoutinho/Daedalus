class_name WallOrientation

const WEST_WALL = "West Wall"
const EAST_WALL = "East Wall"
const NORTH_WALL = "North Wall"
const SOUTH_WALL = "South Wall"

static func symmetric_wall(wall: String) -> String:
	match wall:
		WEST_WALL:
			return EAST_WALL
		EAST_WALL:
			return WEST_WALL
		NORTH_WALL:
			return SOUTH_WALL
		_:
			return NORTH_WALL