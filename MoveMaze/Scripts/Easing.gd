# Easing - a collection of static functions to help 1D non-linear interpolations.

extends Reference

class Helper:
	
	var duration
	var target
	var start
	var ease_func
	
	var t
	
	var enabled
	
	var progress setget , _get_progress
	
	
	func _init(duration, ease_func):
		self.duration = duration
		self.ease_func = ease_func
		self.t = 0
		self.enabled = true
	
	func is_valid():
		return self.progress < 1 and start != null and target != null and enabled
	
	func process(delta):
		self.t += delta
	
	func reset():
		self.t = 0
		
	func _get_progress():
		return self.ease_func.call_func(self.t / self.duration)
	

static func off(t):
	return t

# Utils

static func mix(a, b, blend):
	return a + blend * (b - a)

# Arch

static func arch2(t):
	return t * ( 1 - t)

# Smooth Start

static func smooth_start2(t):
	return pow(t, 2)
	
static func smooth_start3(t):
	return pow(t, 3)
	
static func smooth_start4(t):
	return pow(t, 4)
	
static func smooth_start5(t):
	return pow(t, 5)
	
# Smooth Stop
	
static func smooth_stop2(t):
	return 1 - pow(1 - t, 2)

static func smooth_stop3(t):
	return 1 - pow(1 - t, 3)

static func smooth_stop4(t):
	return 1 - pow(1 - t, 4)

static func smooth_stop5(t):
	return 1 - pow(1 - t, 5)

# Smooth Step

static func smooth_step2(t):
	return mix(smooth_start2(t), smooth_stop2(t), t)

static func smooth_step3(t):
	return mix(smooth_start3(t), smooth_stop3(t), t)
	
static func smooth_step4(t):
	return mix(smooth_start4(t), smooth_stop4(t), t)

static func smooth_step5(t):
	return mix(smooth_start5(t), smooth_stop5(t), t)
	
# Bounce

static func bounce_clamp_bottom(t):
	"""Bounces off the bottom of the [0,1] range since any negative values are now positive."""
	return abs(t)

static func bounce_clamp_top(t):
	"""Bounces off the top of the [0,1] range since any values over 1 become inverted below 1."""
	return 1 - abs(1 - t)
	
static func bounce_clamp_bottom_top(t):
	return bounce_clamp_top(bounce_clamp_bottom(t))
	
