/obj/item/device/paicard
	name = "personal AI device"
	icon = 'icons/obj/aicards.dmi'
	icon_state = "pai"
	item_state = "electronic"
	w_class = 2.0
	slot_flags = SLOT_BELT
	origin_tech = "programming=2"
	var/obj/item/device/radio/radio
	var/looking_for_personality = 1
	var/mob/living/silicon/pai/pai

/obj/item/device/paicard/New()
	..()
	setBaseOverlay()

/obj/item/device/paicard/Destroy()
	//Will stop people throwing friend pAIs into the singularity so they can respawn
	if(!isnull(pai))
		pai.death(0)
	..()

/obj/item/device/paicard/examine()
	if (pai)
		pai.examine()
		return
	else
		return ..()

/obj/item/device/paicard/attack_self(mob/user)
	if (!in_range(src, user))
		return
	user.set_machine(src)
	var/dat = "<TT><B>Personal AI Device</B><BR>"
	if(pai && (!pai.master_dna || !pai.master))
		dat += "<a href='byond://?src=\ref[src];setdna=1'>Imprint Master DNA</a><br>"
	if(pai)
		dat += "Installed Personality: [pai.name]<br>"
		dat += "Prime directive: <br>[pai.laws.zeroth]<br>"
		for(var/slaws in pai.laws.supplied)
			dat += "Additional directives: <br>[slaws]<br>"
		dat += "<a href='byond://?src=\ref[src];setlaws=1'>Configure Directives</a><br>"
		dat += "<br>"
		dat += "<h3>Device Settings</h3><br>"
		if(radio)
			dat += "<b>Radio Uplink</b><br>"
			dat += "Transmit: <A href='byond://?src=\ref[src];wires=[WIRE_TRANSMIT]'>[(radio.wires.IsIndexCut(WIRE_TRANSMIT)) ? "Disabled" : "Enabled"]</A><br>"
			dat += "Receive: <A href='byond://?src=\ref[src];wires=[WIRE_RECEIVE]'>[(radio.wires.IsIndexCut(WIRE_RECEIVE)) ? "Disabled" : "Enabled"]</A><br>"
		else
			dat += "<b>Radio Uplink</b><br>"
			dat += "<font color=red><i>Radio firmware not loaded. Please install a pAI personality to load firmware.</i></font><br>"
		dat += "<A href='byond://?src=\ref[src];wipe=1'>\[Wipe current pAI personality\]</a><br>"
	else
		if(looking_for_personality)
			dat += "Searching for a personality..."
			dat += "<A href='byond://?src=\ref[src];request=1'>\[View available personalities\]</a><br>"
		else
			dat += "No personality is installed.<br>"
			dat += "<A href='byond://?src=\ref[src];request=1'>\[Request personal AI personality\]</a><br>"
			dat += "Each time this button is pressed, a request will be sent out to any available personalities. Check back often and alot time for personalities to respond. This process could take anywhere from 15 seconds to several minutes, depending on the available personalities' timeliness."
	user << browse(dat, "window=paicard")
	onclose(user, "paicard")
	return

/obj/item/device/paicard/Topic(href, href_list)

	if(!usr || usr.stat)
		return

	if(href_list["request"])
		src.looking_for_personality = 1
		SSpai.findPAI(src, usr)

	if(pai)
		if(href_list["setdna"])
			if(pai.master_dna)
				return
			if(!istype(usr, /mob/living/carbon))
				usr << "<span class='notice'>You don't have any DNA, or your DNA is incompatible with this device.</span>"
			else
				var/mob/living/carbon/M = usr
				pai.master = M.real_name
				pai.master_dna = M.dna.unique_enzymes
				pai << "<span class='notice'>You have been bound to a new master.</span>"
		if(href_list["wipe"])
			var/confirm = input("Are you CERTAIN you wish to delete the current personality? This action cannot be undone.", "Personality Wipe") in list("Yes", "No")
			if(confirm == "Yes")
				if(pai)
					pai << "<span class='warning'>You feel yourself slipping away from reality.</span>"
					pai << "<span class='danger'>Byte by byte you lose your sense of self.</span>"
					pai << "<span class='userdanger'>Your mental faculties leave you.</span>"
					pai << "<span class='rose'>oblivion... </span>"
					pai.death(0)
				removePersonality()
		if(href_list["wires"])
			var/t1 = text2num(href_list["wires"])
			if(radio)
				radio.wires.CutWireIndex(t1)
		if(href_list["setlaws"])
			var/newlaws = copytext(sanitize(input("Enter any additional directives you would like your pAI personality to follow. Note that these directives will not override the personality's allegiance to its imprinted master. Conflicting directives will be ignored.", "pAI Directive Configuration", pai.laws.supplied[1]) as message),1,MAX_MESSAGE_LEN)
			if(newlaws && pai)
				pai.add_supplied_law(0,newlaws)
				pai << "Your supplemental directives have been updated. Your new directives are:"
				pai << "Prime Directive : <br>[pai.laws.zeroth]"
				for(var/slaws in pai.laws.supplied)
					pai << "Supplemental Directives: <br>[slaws]"
	attack_self(usr)

// 		WIRE_SIGNAL = 1
//		WIRE_RECEIVE = 2
//		WIRE_TRANSMIT = 4

/obj/item/device/paicard/proc/setPersonality(mob/living/silicon/pai/personality)
	src.pai = personality
	src.pai.description = personality.description
	setEmotionOverlay("pai-null")

/obj/item/device/paicard/proc/removePersonality()
	src.pai = null
	setEmotionOverlay("pai-off")

/obj/item/device/paicard/proc/setAlert()
	setEmotionOverlay("pai-alert")

/obj/item/device/paicard/proc/setBaseOverlay()
	if (SSpai && SSpai.availableRecruitsCount() != 0)
		src.alertUpdate()
	else
		setEmotionOverlay("pai-off")

/obj/item/device/paicard/proc/setEmotion(var/emotion)
	if(pai)
		switch(emotion)
			if(1) setEmotionOverlay("pai-happy")
			if(2) setEmotionOverlay("pai-cat")
			if(3) setEmotionOverlay("pai-extremely-happy")
			if(4) setEmotionOverlay("pai-face")
			if(5) setEmotionOverlay("pai-laugh")
			if(6) setEmotionOverlay("pai-off")
			if(7) setEmotionOverlay("pai-sad")
			if(8) setEmotionOverlay("pai-angry")
			if(9) setEmotionOverlay("pai-what")
			if(10) setEmotionOverlay("pai-null")

/obj/item/device/paicard/proc/setEmotionOverlay(var/overlay)
	src.overlays.Cut()
	src.overlays += overlay

	world << output("[overlay]", "pai.browser:onDisplayChanged")

/obj/item/device/paicard/proc/alertUpdate()
	src.setAlert()
	visible_message("<span class ='info'>[src] flashes a message across its screen, \"Additional personalities available for download.\"", 3, "<span class='notice'>[src] bleeps electronically.</span>", 2)

/obj/item/device/paicard/emp_act(severity)
	if(pai)
		pai.emp_act(severity)
	..()

/obj/item/device/paicard/proc/explode()
	var/turf/T = get_turf(src.loc)

	if (ismob(loc))
		var/mob/M = loc
		M.show_message("\red Your [src] explodes!", 1)
	else if(istype(loc, /obj/item/device/pda))
		var/obj/item/device/pda/P = loc
		if(P.detonate)
			P.explode()
			qdel(src)
			return
	if(T)
		T.hotspot_expose(700,125)

		explosion(T, -1, -1, 2, 3)

	qdel(src)
	return
