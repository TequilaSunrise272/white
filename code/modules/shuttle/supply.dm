GLOBAL_LIST_INIT(blacklisted_cargo_types, typecacheof(list(
		/mob/living,
		/obj/structure/blob,
		/obj/effect/rune,
		/obj/structure/spider/spiderling,
		/obj/item/disk/nuclear,
		/obj/item/beacon,
		/obj/narsie,
		/obj/tear_in_reality,
		/obj/machinery/teleport/station,
		/obj/machinery/teleport/hub,
		/obj/machinery/quantumpad,
		/obj/effect/mob_spawn,
		/obj/effect/hierophant,
		/obj/structure/receiving_pad,
		/obj/item/warp_cube,
		/obj/machinery/rnd/production, //print tracking beacons, send shuttle
		/obj/machinery/autolathe, //same
		/obj/projectile/beam/wormhole,
		/obj/effect/portal,
		/obj/item/shared_storage,
		/obj/structure/extraction_point,
		/obj/machinery/syndicatebomb,
		/obj/item/hilbertshotel,
		/obj/item/swapper,
		/obj/docking_port,
		/obj/machinery/launchpad,
		/obj/machinery/disposal,
		/obj/structure/disposalpipe,
		/obj/item/hilbertshotel,
		/obj/machinery/camera,
		/obj/item/gps,
		/obj/structure/checkoutmachine
	)))

/// How many goody orders we can fit in a lockbox before we upgrade to a crate
#define GOODY_FREE_SHIPPING_MAX 5
/// How much to charge oversized goody orders
#define CRATE_TAX 700

/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"
	callTime = 600

	dir = WEST
	port_direction = EAST
	width = 12
	dwidth = 5
	height = 7
	movement_force = list("KNOCKDOWN" = 0, "THROW" = 0)


	//Export categories for this run, this is set by console sending the shuttle.
	var/export_categories = EXPORT_CARGO

/obj/docking_port/mobile/supply/register()
	. = ..()
	SSshuttle.supply = src

/obj/docking_port/mobile/supply/canMove()
	if(is_station_level(z))
		return check_blacklist(shuttle_areas)
	return ..()

/obj/docking_port/mobile/supply/proc/check_blacklist(areaInstances)
	for(var/place in areaInstances)
		var/area/shuttle/shuttle_area = place
		for(var/trf in shuttle_area)
			var/turf/T = trf
			for(var/a in T.GetAllContents())
				if(is_type_in_typecache(a, GLOB.blacklisted_cargo_types) && !istype(a, /obj/docking_port))
					return FALSE
	return TRUE

/obj/docking_port/mobile/supply/request(obj/docking_port/stationary/S)
	if(mode != SHUTTLE_IDLE)
		return 2
	return ..()

/obj/docking_port/mobile/supply/initiate_docking()
	if(getDockedId() == "supply_away") // Buy when we leave home.
		buy()
	. = ..() // Fly/enter transit.
	if(. != DOCKING_SUCCESS)
		return
	if(getDockedId() == "supply_away") // Sell when we get home
		sell()

/obj/docking_port/mobile/supply/proc/buy()
	var/list/obj/miscboxes = list() //miscboxes are combo boxes that contain all goody orders grouped
	var/list/misc_order_num = list() //list of strings of order numbers, so that the manifest can show all orders in a box
	var/list/misc_contents = list() //list of lists of items that each box will contain

	var/list/empty_turfs = list()
	for(var/place in shuttle_areas)
		var/area/shuttle/shuttle_area = place
		for(var/turf/open/floor/T in shuttle_area)
			if(T.is_blocked_turf())
				continue
			empty_turfs += T

	//quickly and greedily handle chef's grocery runs first, there are a few reasons why this isn't attached to the rest of cargo...
	//but the biggest reason is that the chef requires produce to cook and do their job, and if they are using this system they
	//already got let down by the botanists. So to open a new chance for cargo to also screw them over any more than is necessary is bad.
	if(SSshuttle.chef_groceries.len)
		var/obj/structure/closet/crate/freezer/grocery_crate = new(pick_n_take(empty_turfs))
		grocery_crate.name = "kitchen produce freezer"
		investigate_log("Chef's [SSshuttle.chef_groceries.len] sized produce order arrived. Cost was deducted from orderer, not cargo.", INVESTIGATE_CARGO)
		for(var/datum/orderable_item/item as anything in SSshuttle.chef_groceries)//every order
			for(var/amt in 1 to SSshuttle.chef_groceries[item])//every order amount
				new item.item_instance.type(grocery_crate)
		SSshuttle.chef_groceries.Cut() //This lets the console know it can order another round.

	if(!SSshuttle.shoppinglist.len)
		return

	var/value = 0
	var/purchases = 0
	var/list/goodies_by_buyer = list() // if someone orders more than GOODY_FREE_SHIPPING_MAX goodies, we upcharge to a normal crate so they can't carry around 20 combat shotties

	for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
		if(!empty_turfs.len)
			break
		var/price = SO.pack.cost
		if(SO.applied_coupon)
			price *= (1 - SO.applied_coupon.discount_pct_off)

		var/datum/bank_account/D
		if(SO.paying_account) //Someone paid out of pocket
			D = SO.paying_account
			var/list/current_buyer_orders = goodies_by_buyer[SO.paying_account] // so we can access the length a few lines down
			if(!SO.pack.goody)
				price *= 1.1 //TODO make this customizable by the quartermaster

			// note this is before we increment, so this is the GOODY_FREE_SHIPPING_MAX + 1th goody to ship. also note we only increment off this step if they successfully pay the fee, so there's no way around it
			else if(LAZYLEN(current_buyer_orders) == GOODY_FREE_SHIPPING_MAX)
				price += CRATE_TAX
				D.bank_card_talk("Размер ящика превышает ограничение на бесплатную доставку: взимается комиссия за S&H в размере [CRATE_TAX].")
		else
			D = SSeconomy.get_dep_account(ACCOUNT_CAR)
		if(D)
			if(!D.adjust_money(-price))
				if(SO.paying_account)
					D.bank_card_talk("Заказ на груз № [SO.id] отклонен из-за нехватки средств. Требуются кредиты: [price]")
				continue

		if(SO.paying_account)
			if(SO.pack.goody)
				LAZYADD(goodies_by_buyer[SO.paying_account], SO)
			D.bank_card_talk("Заказ на груз № [SO.id] отправлен. [price] кредиты были зачислены на ваш банковский счет.")
			var/datum/bank_account/department/cargo = SSeconomy.get_dep_account(ACCOUNT_CAR)
			cargo.adjust_money(price - SO.pack.cost) //Cargo gets the handling fee
		value += SO.pack.cost
		SSshuttle.shoppinglist -= SO
		SSshuttle.orderhistory += SO
		QDEL_NULL(SO.applied_coupon)

		if(!SO.pack.goody) //we handle goody crates below
			SO.generate(pick_n_take(empty_turfs))

		SSblackbox.record_feedback("nested tally", "cargo_imports", 1, list("[SO.pack.cost]", "[SO.pack.name]"))
		investigate_log("Заказ № [SO.id] ([SO.pack.name], размещенный [key_name (SO.orderer_ckey)]), оплаченный [D.account_holder], отправлен.", INVESTIGATE_CARGO)
		if(SO.pack.dangerous)
			message_admins("\ [SO.pack.name], заказанный [ADMIN_LOOKUPFLW (SO.orderer_ckey)], оплаченный [D.account_holder], отправлен.")
		purchases++

	// we handle packing all the goodies last, since the type of crate we use depends on how many goodies they ordered. If it's more than GOODY_FREE_SHIPPING_MAX
	// then we send it in a crate (including the CRATE_TAX cost), otherwise send it in a free shipping case
	for(var/D in goodies_by_buyer)
		var/list/buying_account_orders = goodies_by_buyer[D]
		var/datum/bank_account/buying_account = D
		var/buyer = buying_account.account_holder

		if(buying_account_orders.len > GOODY_FREE_SHIPPING_MAX) // no free shipping, send a crate
			var/obj/structure/closet/crate/secure/owned/our_crate = new /obj/structure/closet/crate/secure/owned(pick_n_take(empty_turfs))
			our_crate.buyer_account = buying_account
			our_crate.name = "ящик c припасами - приобретен [buyer]"
			miscboxes[buyer] = our_crate
		else //free shipping in a case
			miscboxes[buyer] = new /obj/item/storage/lockbox/order(pick_n_take(empty_turfs))
			var/obj/item/storage/lockbox/order/our_case = miscboxes[buyer]
			our_case.buyer_account = buying_account
			miscboxes[buyer].name = "груз - куплен [buyer]"
		misc_contents[buyer] = list()

		for(var/O in buying_account_orders)
			var/datum/supply_order/our_order = O
			for (var/item in our_order.pack.contains)
				misc_contents[buyer] += item
			misc_order_num[buyer] = "[misc_order_num[buyer]]#[our_order.id]  "

	for(var/I in miscboxes)
		var/datum/supply_order/SO = new/datum/supply_order()
		SO.id = misc_order_num[I]
		SO.generateCombo(miscboxes[I], I, misc_contents[I])
		qdel(SO)

	var/datum/bank_account/cargo_budget = SSeconomy.get_dep_account(ACCOUNT_CAR)
	investigate_log("[purchases] заказы в этой поставке на сумму кредита [value]. Осталось [cargo_budget.account_balance] кредитов.", INVESTIGATE_CARGO)

/obj/docking_port/mobile/supply/proc/sell()
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	var/presale_points = D.account_balance

	if(!GLOB.exports_list.len) // No exports list? Generate it!
		setupExports()

	var/msg = ""
	var/matched_bounty = FALSE

	var/datum/export_report/ex = new

	for(var/place in shuttle_areas)
		var/area/shuttle/shuttle_area = place
		for(var/atom/movable/AM in shuttle_area)
			if(iscameramob(AM))
				continue
			if(bounty_ship_item_and_contents(AM, dry_run = FALSE))
				matched_bounty = TRUE
			if(!AM.anchored || istype(AM, /obj/vehicle/sealed/mecha))
				export_item_and_contents(AM, export_categories , dry_run = FALSE, external_report = ex)

	if(ex.exported_atoms)
		ex.exported_atoms += "." //ugh

	if(matched_bounty)
		msg += "Предметы из заказа приняты. Консоли заказов должны быть уведомлены. "

	for(var/datum/export/E in ex.total_amount)
		var/export_text = E.total_printout(ex)
		if(!export_text)
			continue

		msg += export_text + "\n"
		D.adjust_money(ex.total_value[E])

	SSshuttle.centcom_message = msg
	investigate_log("Содержимое шаттла продается за кредиты [D.account_balance - presale_points]. Содержит: [ex.exported_atoms? ex.exported_atoms.Join (",") + "." : "none."] Сообщение: [SSshuttle.centcom_message || "none."]", INVESTIGATE_CARGO)

#undef GOODY_FREE_SHIPPING_MAX
#undef CRATE_TAX
