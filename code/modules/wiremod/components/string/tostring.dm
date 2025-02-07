/**
 * # To String Component
 *
 * Converts any value into a string
 */
/obj/item/circuit_component/tostring
	display_name = "В строку"
	desc = "Компонент, который преобразует входные данные в текст."

	/// The input port
	var/datum/port/input/input_port

	/// The result from the output
	var/datum/port/output/output

	circuit_flags = CIRCUIT_FLAG_INPUT_SIGNAL|CIRCUIT_FLAG_OUTPUT_SIGNAL

	var/max_range = 7

/obj/item/circuit_component/tostring/populate_ports()
	input_port = add_input_port("Вход", PORT_TYPE_ANY)
	output = add_output_port("Выход", PORT_TYPE_STRING)

/obj/item/circuit_component/tostring/input_received(datum/port/input/port)

	var/value = input_port.value
	if(isatom(value))
		var/turf/location = get_turf(src)
		var/turf/target_location = get_turf(value)
		if(target_location.z != location.z || get_dist(location, target_location) > max_range)
			output.set_output(PORT_TYPE_ATOM)
			return

	output.set_output("[value]")

