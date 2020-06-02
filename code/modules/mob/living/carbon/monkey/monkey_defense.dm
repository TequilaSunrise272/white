/mob/living/carbon/monkey/help_shake_act(mob/living/carbon/M)
	if(health < 0 && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.do_cpr(src)
	else
		..()

/mob/living/carbon/monkey/attack_paw(mob/living/M)
	if(..()) //successful monkey bite.
		var/dam_zone = pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		if(M.limb_destroyer)
			dismembering_strike(M, affecting.body_zone)
		if(stat != DEAD)
			var/dmg = rand(1, 5)
			apply_damage(dmg, BRUTE, affecting)

/mob/living/carbon/monkey/attack_larva(mob/living/carbon/alien/larva/L)
	if(..()) //successful larva bite.
		var/damage = rand(1, 3)
		if(stat != DEAD)
			L.amount_grown = min(L.amount_grown + damage, L.max_grown)
			var/obj/item/bodypart/affecting = get_bodypart(ran_zone(L.zone_selected))
			if(!affecting)
				affecting = get_bodypart(BODY_ZONE_CHEST)
			apply_damage(damage, BRUTE, affecting)

/mob/living/carbon/monkey/attack_hand(mob/living/carbon/human/M)
	if(..())	//To allow surgery to return properly.
		return

	switch(M.a_intent)
		if("help")
			help_shake_act(M)
		if("grab")
			grabbedby(M)
		if("harm")
			M.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
			if (prob(75))
				visible_message("<span class='danger'>[M] бьёт [name]!</span>", \
								"<span class='userdanger'>[M] бьёт меня!</span>", "<span class='hear'>Слышу как что-то жёстко бьёт по плоти!</span>", COMBAT_MESSAGE_RANGE, M)
				to_chat(M, "<span class='danger'>Бью [name]!</span>")

				playsound(loc, "punch", 25, TRUE, -1)
				var/damage = rand(5, 10)
				if(prob(40))
					damage = rand(10, 15)
					if(AmountUnconscious() < 100 && health > 0)
						Unconscious(rand(200, 300))
						visible_message("<span class='danger'>[M] вырубает [name] нахуй!</span>", \
										"<span class='userdanger'>[M] вырубает меня!</span>", "<span class='hear'>Слышу как что-то жёстко бьёт по плоти!</span>", 5, M)
						to_chat(M, "<span class='danger'>Вырубаю [name] нахуй!</span>")
				var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.zone_selected))
				if(!affecting)
					affecting = get_bodypart(BODY_ZONE_CHEST)
				apply_damage(damage, BRUTE, affecting)
				log_combat(M, src, "атакует")

			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
				visible_message("<span class='danger'>[M] бьёт мимо [name]!</span>", \
								"<span class='danger'>Мне удалось увернуться от атаки [M]!</span>", "<span class='hear'>Слышу взмах!</span>", COMBAT_MESSAGE_RANGE, M)
				to_chat(M, "<span class='warning'>Бью мимо [name]!</span>")
		if("disarm")
			if(stat < UNCONSCIOUS)
				M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
				if (prob(25))
					Paralyze(40)
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
					log_combat(M, src, "pushed")
					visible_message("<span class='danger'>[M] укладывает [src] на пол!</span>", \
									"<span class='userdanger'>[M] укладывает меня на пол!</span>", "<span class='hear'>Слышу звуки потасовки с громким падением!</span>", null, M)
					to_chat(M, "<span class='danger'>Укладываю [src] на пол!</span>")
				else if(dropItemToGround(get_active_held_item()))
					playsound(src, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
					visible_message("<span class='danger'>[M] обезоруживает [src]!</span>", \
									"<span class='userdanger'>[M] обезоруживает меня!</span>", "<span class='hear'>Слышу звуки потасовки!</span>", COMBAT_MESSAGE_RANGE, M)
					to_chat(M, "<span class='danger'>Обезоруживаю [src]!</span>")

/mob/living/carbon/monkey/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(..()) //if harm or disarm intent.
		if (M.a_intent == INTENT_HARM)
			if ((prob(95) && health > 0))
				playsound(loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)
				var/damage = rand(15, 30)
				if (damage >= 25)
					damage = rand(20, 40)
					if(AmountUnconscious() < 300)
						Unconscious(rand(200, 300))
					visible_message("<span class='danger'>[M] разрывает [name]!</span>", \
									"<span class='userdanger'>[M] разрывает меня!</span>", "<span class='hear'>Слышу как что-то жёстко бьёт по плоти!</span>", COMBAT_MESSAGE_RANGE, M)
					to_chat(M, "<span class='danger'>Разрываю [name]!</span>")
				else
					visible_message("<span class='danger'>[M] нарезает [name]!</span>", \
									"<span class='userdanger'>[M] нарезает меня!</span>", "<span class='hear'>Слышу прекрасные звуки нарезки плоти!</span>", COMBAT_MESSAGE_RANGE, M)
					to_chat(M, "<span class='danger'>Нарезаю [name]!</span>")

				var/obj/item/bodypart/affecting = get_bodypart(ran_zone(M.zone_selected))
				log_combat(M, src, "атакует")
				if(!affecting)
					affecting = get_bodypart(BODY_ZONE_CHEST)
				if(!dismembering_strike(M, affecting.body_zone)) //Dismemberment successful
					return 1
				apply_damage(damage, BRUTE, affecting)

			else
				playsound(loc, 'sound/weapons/slashmiss.ogg', 25, TRUE, -1)
				visible_message("<span class='danger'>[M] машет лапой мимо [name]!</span>", \
								"<span class='danger'>Мне удалось увернуться от атаки [M]!</span>", "<span class='hear'>Слышу взмах!</span>", COMBAT_MESSAGE_RANGE, M)
				to_chat(M, "<span class='warning'>Бью мимо [name]!</span>")

		if (M.a_intent == INTENT_DISARM)
			var/obj/item/I = null
			playsound(loc, 'sound/weapons/pierce.ogg', 25, TRUE, -1)
			if(prob(95))
				Paralyze(20)
				visible_message("<span class='danger'>[M] вдавливает [name] в пол!</span>", \
								"<span class='userdanger'>[M] вдавливает меня в пол!</span>", "<span class='hear'>Слышу звуки потасовки с громким падением!</span>", COMBAT_MESSAGE_RANGE, M)
				to_chat(M, "<span class='danger'>Вдавливаю [name] в пол!</span>")
			else
				I = get_active_held_item()
				if(dropItemToGround(I))
					visible_message("<span class='danger'>[M] обезоруживает [name]!</span>", \
									"<span class='userdanger'>[M] обезоруживает меня!</span>", "<span class='hear'>Слышу звуки потасовки!</span>", COMBAT_MESSAGE_RANGE, M)
					to_chat(M, "<span class='danger'>Обезоруживаю [name]!</span>")
				else
					I = null
			log_combat(M, src, "disarmed", "[I ? " removing \the [I]" : ""]")
			updatehealth()


/mob/living/carbon/monkey/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		var/dam_zone = dismembering_strike(M, pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(!dam_zone) //Dismemberment successful
			return TRUE
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		apply_damage(damage, M.melee_damage_type, affecting)

/mob/living/carbon/monkey/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		var/damage = rand(5, 35)
		if(M.is_adult)
			damage = rand(20, 40)
		var/dam_zone = dismembering_strike(M, pick(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(!dam_zone) //Dismemberment successful
			return 1
		var/obj/item/bodypart/affecting = get_bodypart(ran_zone(dam_zone))
		if(!affecting)
			affecting = get_bodypart(BODY_ZONE_CHEST)
		apply_damage(damage, BRUTE, affecting)

/mob/living/carbon/monkey/acid_act(acidpwr, acid_volume, bodyzone_hit)
	. = 1
	if(!bodyzone_hit || bodyzone_hit == BODY_ZONE_HEAD)
		if(wear_mask)
			if(!(wear_mask.resistance_flags & UNACIDABLE))
				wear_mask.acid_act(acidpwr, acid_volume)
			else
				to_chat(src, "<span class='warning'>Моя маска защищает меня от кислоты.</span>")
			return
		if(head)
			if(!(head.resistance_flags & UNACIDABLE))
				head.acid_act(acidpwr, acid_volume)
			else
				to_chat(src, "<span class='warning'>Мой головной убор защищает меня от кислоты.</span>")
			return
	take_bodypart_damage(acidpwr * min(0.6, acid_volume*0.1))


/mob/living/carbon/monkey/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	..()
	if(QDELETED(src))
		return
	switch (severity)
		if (EXPLODE_DEVASTATE)
			gib()
			return

		if (EXPLODE_HEAVY)
			take_overall_damage(60, 60)
			damage_clothes(200, BRUTE, "bomb")
			adjustEarDamage(30, 120)
			if(prob(70))
				Unconscious(200)

		if(EXPLODE_LIGHT)
			take_overall_damage(30, 0)
			damage_clothes(50, BRUTE, "bomb")
			adjustEarDamage(15,60)
			if (prob(50))
				Unconscious(160)


	//attempt to dismember bodyparts
	if(severity <= 2)
		var/max_limb_loss = round(4/severity) //so you don't lose four limbs at severity 3.
		for(var/X in bodyparts)
			var/obj/item/bodypart/BP = X
			if(prob(50/severity) && BP.body_zone != BODY_ZONE_CHEST)
				BP.brute_dam = BP.max_damage
				BP.dismember()
				max_limb_loss--
				if(!max_limb_loss)
					break
