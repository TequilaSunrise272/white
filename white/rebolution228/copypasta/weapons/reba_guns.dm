///////////////////////////////////////////  HS 010 SMG
// наследие кулдена, нигде не используется, жестко лагает, планировалось добавить триторам
/obj/item/gun/ballistic/automatic/hs010
	name = "HS 010"
	desc = "Произведенный компанией CROON, этот пистолет-пулемёт прославлен за свою крайне высокую скорострельность. Использовался не только армиями различных частных корпораций, но и террористами всех сортов. Использует 2,5мм калибр."
	icon = 'white/rebolution228/icons/weapons/rguns.dmi'
	icon_state = "hs010"
	inhand_icon_state = "hs010"
	lefthand_file = 'white/rebolution228/icons/weapons/guns_inhand_left.dmi'
	righthand_file = 'white/rebolution228/icons/weapons/guns_inhand_right.dmi'
	mag_type = /obj/item/ammo_box/magazine/hs010
	pin = /obj/item/firing_pin
	fire_delay = 0
	burst_size = 1
	spread = 10
	w_class = WEIGHT_CLASS_NORMAL
	weapon_weight = WEAPON_LIGHT
	flags_1 = CONDUCT_1

	fire_sound = 'white/baldenysh/sounds/eyedc/HS_STEREO_FIRE_SOSANIE.ogg'
	fire_sound_volume = 25

	eject_sound = 'white/baldenysh/sounds/eyedc/hs_reload_02.wav'
	eject_empty_sound = 'white/baldenysh/sounds/eyedc/hs_reload_02.wav'
	load_sound = 'white/baldenysh/sounds/eyedc/hs_reload_02.wav'
	load_empty_sound = 'white/baldenysh/sounds/eyedc/hs_reload_02.wav'
	rack_sound = 'white/baldenysh/sounds/eyedc/hs_reload_03.wav'

	actions_types = list()
	can_suppress = FALSE
	var/fuller_auto = FALSE
	var/tail_sound = 'white/baldenysh/sounds/eyedc/HS_STEREO_FIRE_TAIL.wav'
// компонент для ствола, делающий звук зацикленным
/obj/item/gun/ballistic/automatic/hs010/Initialize()
	. = ..()
	AddComponent(/datum/component/automatic_fire_funny, 1)
	RegisterSignal(src, COMSIG_AUTOFIRE_STOPPED, .proc/play_tail_sound)

/obj/item/gun/ballistic/automatic/hs010/proc/play_tail_sound()
	SIGNAL_HANDLER
	playsound(get_turf(src), tail_sound, 50)
// режимы стрельбы
/obj/item/gun/ballistic/automatic/hs010/AltClick(mob/user)
	. = ..()
	fuller_auto = !fuller_auto
	balloon_alert(user, "режим: [fuller_auto ? "fuller" : "full"] auto")
	if(fuller_auto)
		var/datum/component/automatic_fire_funny/D = GetComponent(/datum/component/automatic_fire_funny)
		D.autofire_shot_delay = 0.1
		spread = 10
		fire_sound = 'white/baldenysh/sounds/eyedc/HS_STEREO_FIRE_HSPEED_SOSANIE.ogg'
		tail_sound = 'white/baldenysh/sounds/eyedc/HS_STEREO_FIRE_HSPEED_TAIL.wav'
	else
		var/datum/component/automatic_fire_funny/D = GetComponent(/datum/component/automatic_fire_funny)
		D.autofire_shot_delay = 1
		spread = 30
		fire_sound = 'white/baldenysh/sounds/eyedc/HS_STEREO_FIRE_SOSANIE.ogg'
		tail_sound = 'white/baldenysh/sounds/eyedc/HS_STEREO_FIRE_TAIL.wav'
// магазин
/obj/item/ammo_box/magazine/hs010
	name = "HS 010 Magazine"
	icon = 'white/rebolution228/icons/weapons/rammo.dmi'
	icon_state = "hs010ammo"
	ammo_type = /obj/item/ammo_casing/c25mm
	caliber = "c25mm"
	max_ammo = 100

/obj/item/ammo_box/magazine/hs010/update_icon()
	..()
	if(ammo_count() == 0)
		icon_state = "hs010ammo_e"
	else
		icon_state = "hs010ammo"
// изначально пустой магазин
/obj/item/ammo_box/magazine/hs010/empty
	start_empty = TRUE
// патрон
/obj/item/ammo_casing/c25mm
	name = "2,5мм гильза"
	caliber = "c25mm"
	projectile_type = /obj/projectile/bullet/c25mm
// пуля
/obj/projectile/bullet/c25mm
	name = "2,5мм пуля"
	damage = 14
	armour_penetration = 0
	wound_bonus = 2
// коробка с патронами
/obj/item/ammo_box/c25mm
	name = "коробка с патронами (2,5mm)"
	icon_state = "10mmbox" //аааааааааааааааааааааааааааааааааааааааааааааааааааа?
	ammo_type = /obj/item/ammo_casing/c25mm
	max_ammo = 100
//  плата для диска, чтобы печатать патроны
/obj/item/disk/design_disk/adv/hs010_ammo
	name = "HS 010 Ammo and Mags"

/obj/item/disk/design_disk/adv/hs010_ammo/Initialize()
	. = ..()
	var/datum/design/hs010_mag/M = new
	var/datum/design/c25mm_box/B = new
	blueprints[1] = M
	blueprints[2] = B
// схема коробки в автолате
/datum/design/c25mm_box
	name = "Ammo Box (2.5mm)"
	desc = "Коробка патронов калибра 2,5мм."
	id = "hs010_ammo"
	build_type = AUTOLATHE
	materials = list(MAT_CATEGORY_RIGID = 30000)
	build_path = /obj/item/ammo_box/c25mm
	category = list("Импорт")
// схема магазина в автолате
/datum/design/hs010_mag
	name = "HS 010 Magazine"
	desc = "Это магазин......... Что еще сказать....."
	id = "hs010_mag"
	build_type = AUTOLATHE
	materials = list(MAT_CATEGORY_RIGID = 2500)
	build_path = /obj/item/ammo_box/magazine/hs010/empty
	category = list("Импорт")
