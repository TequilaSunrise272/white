
#define STATION_HOLODECK		(1<<0)
#define CUSTOM_HOLODECK_ONE		(1<<1)
#define CUSTOM_HOLODECK_TWO		(1<<2)
#define HOLODECK_DEBUG			(1<<3)//you should never see this

/datum/map_template/holodeck
	var/template_id
	var/description
	var/access_flags //bitflags representing what holodeck is allowed to access them
	var/restricted = FALSE
	var/datum/parsed_map/lastparsed

	should_place_on_top = FALSE
	returns_created_atoms = TRUE
	keep_cached_map = TRUE

	var/obj/machinery/computer/holodeck/linked

/datum/map_template/holodeck/offline
	name = "Голодек: Оффлайн"
	template_id = "holodeck_offline"
	description = "benis"
	mappath = "_maps/templates/holodeck_offline.dmm"
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/emptycourt
	name = "Голодек: Пустое поле"
	template_id = "holodeck_emptycourt"
	description = "benis"
	mappath = "_maps/templates/holodeck_emptycourt.dmm"
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/dodgeball
	name = "Голодек: Поле доджбола"
	template_id = "holodeck_dodgeball"
	description = "benis"
	mappath = "_maps/templates/holodeck_dodgeball.dmm"
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/basketball
	name = "Голодек: Поле баскетбола"
	template_id = "holodeck_basketball"
	description = "benis"
	mappath = "_maps/templates/holodeck_basketball.dmm"
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/thunderdome
	name = "Голодек: Арена тандердома"
	template_id = "holodeck_thunderdome"
	description = "benis"
	mappath = "_maps/templates/holodeck_thunderdome.dmm"
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/beach
	name = "Голодек: Пляж"
	template_id = "holodeck_beach"
	description = "benis"
	mappath = "_maps/templates/holodeck_beach.dmm"
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/lounge
	name = "Голодек: Гостиная"
	template_id = "holodeck_lounge"
	description = "benis"
	mappath = "_maps/templates/holodeck_lounge.dmm"
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/petpark
	name = "Голодек: Парк животных"
	template_id = "holodeck_petpark"
	description = "benis"
	mappath = "_maps/templates/holodeck_petpark.dmm"
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/firingrange
	name = "Голодек: Тир"
	template_id = "holodeck_firingrange"
	description = "benis"
	mappath = "_maps/templates/holodeck_firingrange.dmm"
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/anime_school
	name = "Голодек: Аниме-школа"
	template_id = "holodeck_animeschool"
	description = "benis"
	mappath = "_maps/templates/holodeck_animeschool.dmm"
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/chapelcourt
	name = "Голодек: Пыточная церкви"
	template_id = "holodeck_chapelcourt"
	description = "benis"
	mappath = "_maps/templates/holodeck_chapelcourt.dmm"
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/spacechess
	name = "Голодек: Космошахматы"
	template_id = "holodeck_spacechess"
	description = "benis"
	mappath = "_maps/templates/holodeck_spacechess.dmm"
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/spacecheckers
	name = "Голодек: Космошашки"
	template_id = "holodeck_spacecheckers"
	description = "benis"
	mappath = "_maps/templates/holodeck_spacecheckers.dmm"
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/kobayashi
	name = "Голодек: Кобаяши Мару"
	template_id = "holodeck_kobayashi"
	description = "benis"
	mappath = "_maps/templates/holodeck_kobayashi.dmm"
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/winterwonderland
	name = "Голодек: Зимняя сказка"
	template_id = "holodeck_winterwonderland"
	description = "benis"
	mappath = "_maps/templates/holodeck_winterwonderland.dmm"
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/photobooth
	name = "Голодек: Фотокабина"
	template_id = "holodeck_photobooth"
	description = "benis"
	mappath = "_maps/templates/holodeck_photobooth.dmm"
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/skatepark
	name = "Голодек: Скейт-парк"
	template_id = "holodeck_skatepark"
	description = "benis"
	mappath = "_maps/templates/holodeck_skatepark.dmm"
	access_flags = STATION_HOLODECK

//bad evil no good programs

/datum/map_template/holodeck/medicalsim
	name = "Голодек: Медбей"
	template_id = "holodeck_medicalsim"
	description = "benis"
	mappath = "_maps/templates/holodeck_medicalsim.dmm"
	restricted = TRUE
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/thunderdome1218
	name = "Голодек: 1218 AD"
	template_id = "holodeck_thunderdome1218"
	description = "benis"
	mappath = "_maps/templates/holodeck_thunderdome1218.dmm"
	restricted = TRUE
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/burntest
	name = "Голодек: Тест Атмоса"
	template_id = "holodeck_burntest"
	description = "benis"
	mappath = "_maps/templates/holodeck_burntest.dmm"
	restricted = TRUE
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/wildlifesim
	name = "Голодек: Моделирование дикой природы"
	template_id = "holodeck_wildlifesim"
	description = "benis"
	mappath = "_maps/templates/holodeck_wildlifesim.dmm"
	restricted = TRUE
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/holdoutbunker
	name = "Голодек: Бункер защиты"
	template_id = "holodeck_holdoutbunker"
	description = "benis"
	mappath = "_maps/templates/holodeck_holdoutbunker.dmm"
	restricted = TRUE
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/anthophillia
	name = "Голодек: Антофилия"
	template_id = "holodeck_anthophillia"
	description = "benis"
	mappath = "_maps/templates/holodeck_anthophillia.dmm"
	restricted = TRUE
	access_flags = STATION_HOLODECK

/datum/map_template/holodeck/refuelingstation
	name = "Голодек: Заправочная станция"
	template_id = "holodeck_refuelingstation"
	description = "benis"
	mappath = "_maps/templates/holodeck_refuelingstation.dmm"
	restricted = TRUE
	access_flags = STATION_HOLODECK

//flag debug holodeck

/datum/map_template/holodeck/gamer
	name = "Голодек: Gamer"
	template_id = "holodeck_gamer"
	description = "benis"
	mappath = "_maps/templates/holodeck_gamer.dmm"
	access_flags = HOLODECK_DEBUG
