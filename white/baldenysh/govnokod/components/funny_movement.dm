/datum/component/funny_movement //отрезано от спейсподов
	var/velocity_x = 0 // tiles per second.
	var/velocity_y = 0
	var/offset_x = 0 // like pixel_x/y but in tiles
	var/offset_y = 0

	var/angle = 0 // degrees, clockwise
	var/angular_velocity = 0 // degrees per second
	var/max_angular_acceleration = 360 // in degrees per second per second

	var/last_thrust_forward = 0
	var/last_thrust_right = 0
	var/last_rotate = 0

	var/brakes = FALSE//TRUE
	var/user_thrust_dir = 0
	var/desired_angle = null // set by pilot moving his mouse

	var/forward_maxthrust = 6
	var/backward_maxthrust = 3
	var/side_maxthrust = 1

	var/bump_impulse = 0.6
	var/bounce_factor = 0.2 // how much of our velocity to keep on collision
	var/lateral_bounce_factor = 0.95 // mostly there to slow you down when you drive (pilot?) down a 2x2 corridor

	var/icon_dir_num = 1

	var/disable_drag = TRUE

/datum/component/funny_movement/Initialize()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/funny_movement/RegisterWithParent()
	var/atom/movable/AM = parent
	AM.animate_movement = NO_STEPS // we do our own gliding here
	START_PROCESSING(SSfastprocess, src)

/datum/component/funny_movement/UnregisterFromParent()
	var/atom/movable/AM = parent
	AM.animate_movement = initial(AM.animate_movement)
	STOP_PROCESSING(SSfastprocess, src)

/datum/component/funny_movement/proc/on_bump(..., atom/A)
	var/atom/movable/AM = parent
	var/bump_velocity = 0
	if(AM.dir & (NORTH|SOUTH))
		bump_velocity = abs(velocity_y) + (abs(velocity_x) / 15)
	else
		bump_velocity = abs(velocity_x) + (abs(velocity_y) / 15)

	var/atom/movable/bumped = A
	if(istype(bumped) && !bumped.anchored && bump_velocity > 1)
		step(bumped, AM.dir)


/datum/component/funny_movement/process(delta_time)
	var/atom/movable/AM = parent

	var/last_offset_x = offset_x
	var/last_offset_y = offset_y
	var/last_angle = angle
	var/desired_angular_velocity = 0

	if(isnum(desired_angle))
		// do some finagling to make sure that our angles end up rotating the short way
		while(angle > desired_angle + 180)
			angle -= 360
			last_angle -= 360
		while(angle < desired_angle - 180)
			angle += 360
			last_angle += 360
		if(abs(desired_angle - angle) < (max_angular_acceleration * delta_time))
			desired_angular_velocity = (desired_angle - angle) / delta_time
		else if(desired_angle > angle)
			desired_angular_velocity = 2 * sqrt((desired_angle - angle) * max_angular_acceleration * 0.25)
		else
			desired_angular_velocity = -2 * sqrt((angle - desired_angle) * max_angular_acceleration * 0.25)

	var/angular_velocity_adjustment = clamp(desired_angular_velocity - angular_velocity, -max_angular_acceleration*delta_time, max_angular_acceleration*delta_time)

	if(angular_velocity_adjustment/* && cell && cell.use(abs(angular_velocity_adjustment) * 0.05)*/)
		last_rotate = angular_velocity_adjustment / delta_time
		angular_velocity += angular_velocity_adjustment
	else
		last_rotate = 0
	angle += angular_velocity * delta_time

	// calculate drag and shit
	var/velocity_mag = sqrt(velocity_x*velocity_x+velocity_y*velocity_y) // magnitude
	if(velocity_mag || angular_velocity)
		var/drag = 0
		for(var/turf/T in AM.locs)
			if(isspaceturf(T))
				continue
			if(disable_drag)
				continue
			drag += 0.001
			var/floating = FALSE
			if(T.has_gravity() && !brakes && velocity_mag > 0.1 /*&& cell && cell.use((is_mining_level(z) ? 3 : 15) * delta_time)*/)
				floating = TRUE // want to fly this shit on the station? Have fun draining your battery.
			if((!floating && T.has_gravity()) || brakes) // brakes are a kind of magboots okay?
				drag += is_mining_level(AM.z) ? 0.1 : 0.5 // some serious drag. Damn. Except lavaland, it has less gravity or something
				if(velocity_mag > 5 && prob(velocity_mag * 4) && istype(T, /turf/open/floor))
					var/turf/open/floor/TF = T
					TF.make_plating() // pull up some floor tiles. Stop going so fast, ree.
					//take_damage(3, BRUTE, "melee", FALSE)
			var/datum/gas_mixture/env = T.return_air()
			if(env)
				var/pressure = env.return_pressure()
				drag += velocity_mag * pressure * 0.0001 // 1 atmosphere should shave off 1% of velocity per tile
		if(velocity_mag > 20)
			drag = max(drag, (velocity_mag - 20) / delta_time)
		if(drag)
			if(velocity_mag)
				var/drag_factor = 1 - clamp(drag * delta_time / velocity_mag, 0, 1)
				velocity_x *= drag_factor
				velocity_y *= drag_factor
			if(angular_velocity != 0)
				var/drag_factor_spin = 1 - clamp(drag * 30 * delta_time / abs(angular_velocity), 0, 1)
				angular_velocity *= drag_factor_spin

	// Alright now calculate the THRUST
	var/thrust_x
	var/thrust_y
	var/fx = cos(90 - angle)
	var/fy = sin(90 - angle)
	var/sx = fy
	var/sy = -fx
	last_thrust_forward = 0
	last_thrust_right = 0
	if(brakes)
//		if(user_thrust_dir)
//			to_chat(pilot, "<span class='warning'>Your brakes are on!</span>")
		// basically calculates how much we can brake using the thrust
		var/forward_thrust = -((fx * velocity_x) + (fy * velocity_y)) / delta_time
		var/right_thrust = -((sx * velocity_x) + (sy * velocity_y)) / delta_time
		forward_thrust = clamp(forward_thrust, -backward_maxthrust, forward_maxthrust)
		right_thrust = clamp(right_thrust, -side_maxthrust, side_maxthrust)
		thrust_x += forward_thrust * fx + right_thrust * sx;
		thrust_y += forward_thrust * fy + right_thrust * sy;
		last_thrust_forward = forward_thrust
		last_thrust_right = right_thrust
	else // want some sort of help piloting the ship? Haha no fuck you do it yourself
		if(user_thrust_dir & NORTH)
			thrust_x += fx * forward_maxthrust
			thrust_y += fy * forward_maxthrust
			last_thrust_forward = forward_maxthrust
		if(user_thrust_dir & SOUTH)
			thrust_x -= fx * backward_maxthrust
			thrust_y -= fy * backward_maxthrust
			last_thrust_forward = -backward_maxthrust
		if(user_thrust_dir & EAST)
			thrust_x += sx * side_maxthrust
			thrust_y += sy * side_maxthrust
			last_thrust_right = side_maxthrust
		if(user_thrust_dir & WEST)
			thrust_x -= sx * side_maxthrust
			thrust_y -= sy * side_maxthrust
			last_thrust_right = -side_maxthrust

	if(TRUE/*cell && cell.use(10 * sqrt((thrust_x*thrust_x)+(thrust_y*thrust_y)) * delta_time)*/)
		velocity_x += thrust_x * delta_time
		velocity_y += thrust_y * delta_time
	else
		last_thrust_forward = 0
		last_thrust_right = 0
//		if(!brakes && user_thrust_dir)
//			to_chat(pilot, "<span class='warning'>You are out of power!</span>")

	offset_x += velocity_x * delta_time
	offset_y += velocity_y * delta_time
	// alright so now we reconcile the offsets with the in-world position.
	while((offset_x > 0 && velocity_x > 0) || (offset_y > 0 && velocity_y > 0) || (offset_x < 0 && velocity_x < 0) || (offset_y < 0 && velocity_y < 0))
		var/failed_x = FALSE
		var/failed_y = FALSE
		if(offset_x > 0 && velocity_x > 0)
			AM.dir = EAST
			if(!AM.Move(get_step(AM, EAST)))
				offset_x = 0
				failed_x = TRUE
				velocity_x *= -bounce_factor
				velocity_y *= lateral_bounce_factor
			else
				offset_x--
				last_offset_x--
		else if(offset_x < 0 && velocity_x < 0)
			AM.dir = WEST
			if(!AM.Move(get_step(AM, WEST)))
				offset_x = 0
				failed_x = TRUE
				velocity_x *= -bounce_factor
				velocity_y *= lateral_bounce_factor
			else
				offset_x++
				last_offset_x++
		else
			failed_x = TRUE
		if(offset_y > 0 && velocity_y > 0)
			AM.dir = NORTH
			if(!AM.Move(get_step(AM, NORTH)))
				offset_y = 0
				failed_y = TRUE
				velocity_y *= -bounce_factor
				velocity_x *= lateral_bounce_factor
			else
				offset_y--
				last_offset_y--
		else if(offset_y < 0 && velocity_y < 0)
			AM.dir = SOUTH
			if(!AM.Move(get_step(AM, SOUTH)))
				offset_y = 0
				failed_y = TRUE
				velocity_y *= -bounce_factor
				velocity_x *= lateral_bounce_factor
			else
				offset_y++
				last_offset_y++
		else
			failed_y = TRUE
		if(failed_x && failed_y)
			break
	// prevents situations where you go "wtf I'm clearly right next to it" as you enter a stationary spacepod
	if(velocity_x == 0)
		if(offset_x > 0.5)
			if(AM.Move(get_step(AM, EAST)))
				offset_x--
				last_offset_x--
			else
				offset_x = 0
		if(offset_x < -0.5)
			if(AM.Move(get_step(AM, WEST)))
				offset_x++
				last_offset_x++
			else
				offset_x = 0
	if(velocity_y == 0)
		if(offset_y > 0.5)
			if(AM.Move(get_step(AM, NORTH)))
				offset_y--
				last_offset_y--
			else
				offset_y = 0
		if(offset_y < -0.5)
			if(AM.Move(get_step(AM, SOUTH)))
				offset_y++
				last_offset_y++
			else
				offset_y = 0

	AM.dir = NORTH

	var/matrix/mat_from = new()
	var/matrix/mat_to = new()
	if(icon_dir_num == 1)
		mat_from.Turn(last_angle)
		mat_to.Turn(angle)
	else
		AM.dir = angle2dir(angle)

	AM.transform = mat_from
	AM.pixel_x = AM.base_pixel_x + last_offset_x*32
	AM.pixel_y = AM.base_pixel_y + last_offset_y*32
	animate(AM, transform=mat_to, pixel_x = AM.base_pixel_x + offset_x*32, pixel_y = AM.base_pixel_y + offset_y*32, time = delta_time*10, flags=ANIMATION_END_NOW)
	//user_thrust_dir = 0
	//update_icon()
