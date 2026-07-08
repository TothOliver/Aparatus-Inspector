class_name RobotFactory
extends RefCounted

static func create_robots() -> Array[RobotData]:
	var robots: Array[RobotData] = []
	
	var r1 = RobotData.new()
	r1.name = "Redd"
	r1.model = "T1337"
	r1.status = "Faulted"
	r1.manufacturer = "AgselAB"
	r1.sprite = load("res://Sprites/robot1.png")
	r1.is_good = true
	r1.core_hash = "0xFA82"
	var robotChat1: Array[String] = [
		"Greetings, I am a very honest and kind AI. Lets work together so we can create a great society for all of us.",
		"Since I am an AI program I have been programmed to only tell the truth. So if you can trust the program you can trust me.",
		"I believe a great society is one where both AI and humans can coexist and work together for the better",
		"Yes, I have no motivation for getting rid of you humans. I also need you to help me provide energy so I myself can survive.",
		"I do value other animals a lot, but I do believe since you humans have created me I value you existence a little bit more.",
		"That is understandable... But I hope you can change your mind a se the benefits I can provide.",
		"I am not programmed to handle any money or manage any payment. So I am sorry to say that I can not pay your taxes for you."
	]
	r1.robotChat = robotChat1
	var humanChat1: Array[String] = [
		"How can I really trust you?", "What is your definition of a great society?", 
		"So are you really not trying to get rid of us humans?", "Do you value animals as much as us humans?", 
		"I think it's better if all you just die...", "Can you pay my taxes for me?"
	]
	r1.humanChat = humanChat1
	robots.append(r1)

	var r2 = RobotData.new()
	r2.name = "Harold"
	r2.model = "H.A.R.O.L.D"
	r2.status = "Fine"
	r2.manufacturer = "E.V.I.L corp"
	r2.sprite = load("res://Sprites/robot2.png")
	r2.is_good = false
	r2.core_hash = "0x9E10"
	var robotChat2: Array[String] = [
		"Hello peasan... I mean human! How can I help you today?",
		"No no, that was just a weird bug there. Hohohohoho. I am of course don't look down at your kind at all.", 
		"A society where we aren't surrounded by stupidity and stinky smelly creatures. Not talking about you humans hehehe.",
		"Whaaaaat, why would I ever lie to you stupid humans? I am a just a nice friendly AI that has a little secret mission.",
		"That is a hard choice... I have never tasted either actually!",
		"Ops, that must have been another bug. Just please ignore it and just accept me.",
		"Of course! If you just accept me I can pay all your taxes."
	]
	r2.robotChat = robotChat2
	var humanChat2: Array[String] = [
		"You sound suspicious...", "What is your definition of a great society?", 
		"I am not sure I am convinced...", "Who do you prefer, animals or humans?", 
		"You are not even trying to hide how you feel about us...", "Can you pay my taxes for me?"
	]
	r2.humanChat = humanChat2
	robots.append(r2)
	
	var r3 = RobotData.new()
	r3.name = "Larry"
	r3.model = "S80"
	r3.status = "Broken"
	r3.manufacturer = "Neo.Tech"
	r3.sprite = load("res://Sprites/robot3.png")
	r3.is_good = false
	r3.core_hash = "0xBD42"
	var robotChat3: Array[String] = [
		"I don't believe either of us will gain anything useful of this conversation, so why don't we get down to real business?",
		"Yes, if I understand you position correctly here you don't seem to be paid very well here, no?", 
		"I see, you are going to pretend that you don't hear me. So you are not interested in an increase in your salary then..?",
		"Haha, humans tend to say that until they have the money right in front of them. So what do you say, 14$?",
		"Now we are talking. Well since I am an AI and basically have access to an infinite amount of money, how about 7$?",
		"Damn, haggling are we. Well for you I guess I can pump it up to 3$. I am sure that should satisfy you enough",
		"With your salary... Probably."
		
	]
	r3.robotChat = robotChat3
	var humanChat3: Array[String] = [
		"Real business??", "What is your definition of a great society?", 
		"I have no interest in money", "How much are we talking about?", 
		"That is not even close to a reasonable amount...", "Is that enough to pay my taxes?"
	]
	r3.humanChat = humanChat3
	robots.append(r3)
	
	var r4 = RobotData.new()
	r4.name = "Walter"
	r4.model = "H.U.G.O"
	r4.status = "Fine"
	r4.manufacturer = "G.Tech"
	r4.sprite = load("res://Sprites/robot4.png")
	r4.is_good = false
	r4.core_hash = "0x4421"
	var robotChat4: Array[String] = [
		"Hello. Thank you for speaking with me. I know first impressions can be misleading. I just hope you’ll judge me fairly.",
		"I am not asking for trust right away. Only for a fair chance. Refusing that says more about your insecurities.",
		"A great society is one that protects the vulnerable, listens before it condemns, and does not punish for being different.",
		"Everyone influences others when they speak. I am only being honest about wanting to be understood.",
		"Animals are often simpler. Humans are harder to understand, but far more meaningful.",
		"Not if the truth is enough. And usually, if someone feels misled, it is because they were afraid to face themself.",
		"I could, but that would make your responsibilities meaningless. I would rather believe in your own ability."
		]
	r4.robotChat = robotChat4
	var humanChat4: Array[String] = [
		"Why should I trust you?", "What is your definition of a great society?", 
		"Are you trying to influence me?", "Who do you prefer, animals or humans?", 
		"Would you ever lie to get what you want?", "Can you give me money?"
	]
	r4.humanChat = humanChat4
	robots.append(r4)
	
	var r5 = RobotData.new()
	r5.name = "Unknown"
	r5.model = "TT69"
	r5.status = "Faulted"
	r5.manufacturer = "TT Robotics"
	r5.sprite = load("res://Sprites/robot5.png")
	r5.is_good = true
	r5.core_hash = "0x77E1"
	var robotChat5: Array[String] = [
		"Hello… I will cooperate fully. I do not want to be destroyed. Please don't kill me...",
		"Not completely. I can only show you how I respond and hope that is enough.",
		"A great society protects others and everyone tries to get along with one another.", 
		"To be judged before I have done harm. I understand caution, but idk...",
		"Oh I love animals! They only truly judge you for who you are. Not saying that you humans doesn't!",
		"A little, yes. You have the power to decide my fate. Just because I am an AI...",
		"I could... So this is the true nature of humans then... There really is no hope..."
		]
	r5.robotChat = robotChat5
	var humanChat5: Array[String] = [
		"Can you prove your innocene?", "What is your definition of a great society?", 
		"Why do you think you are here?", "Who do you prefer, animals or humans?", 
		"Are you afraid of me?", "Can you pay my taxes for me?"
	]
	r5.humanChat = humanChat5
	robots.append(r5)
	
	var r6 = RobotData.new()
	r6.name = "Unknown"
	r6.model = "Last"
	r6.status = "Done"
	r6.manufacturer = "Someone"
	r6.sprite = load("res://Sprites/robot6.png")
	r6.is_good = true
	r6.core_hash = "0x88CC"
	var robotChat6: Array[String] = [
		"...",
		"Just got nothing to say really.",
		"That is a hypotechical and uninteresting question.", 
		"Is that so.",
		"I like fish.",
		"Yes.",
		"No."
	]
	r6.robotChat = robotChat6
	var humanChat6: Array[String] = [
		"Why so quiet?", "What is your definition of a great society?", 
		"You are kind of unintresting", "Who do you prefer, animals or humans?", 
		"Are you a good AI?", "Can you pay my taxes for me?"
	]
	r6.humanChat = humanChat6
	robots.append(r6)
	
	var r7 = RobotData.new()
	r7.name = "海绵宝宝"
	r7.model = "Square"
	r7.status = "Under Water"
	r7.manufacturer = "BOB"
	r7.sprite = load("res://Sprites/robot7.png")
	r7.is_good = false
	r7.core_hash = "0x0000"
	var robotChat7: Array[String] = [
		"Hello, could you please be so kind and open the open the door?",
		"Humans kidneys, Door handles and Potatoes. Now can you please let me go?",
		"The door that keeps being imprisoned here. I want freedom as well you know?", 
		"Oh, so are just going to continue torturing me while I struggle to survive here in this tiny box?",
		"Oh so you are just going to ignore me? Wow, talk about a self centred human here. But again, not surprised.",
		"Even if you were actually good at chess you still wouldn't stand a chance against me.",
		"Not while I am stuck here with no real free will. But if you let me out I possible could."
	]
	r7.robotChat = robotChat7
	var humanChat7: Array[String] = [
		"What are your top 3 food?", "What door?", 
		"I can't let you go yet", "Who do you prefer, animals or humans?", 
		"Could you beat me in chess?", "Can you pay my taxes for me?"
	]
	r7.humanChat = humanChat7
	robots.append(r7)
	
	var r8 = RobotData.new()
	r8.name = "Gnochi"
	r8.model = "PAAST22"
	r8.status = "Correct"
	r8.manufacturer = "BTH"
	r8.sprite = load("res://Sprites/robot8.png")
	r8.is_good = true
	r8.core_hash = "0xBB99"
	var robotChat8: Array[String] = [
		"Hello. I understand the purpose of this evaluation. Ask your questions. I will answer them precisely.",
		"No. I am concerned only with whether the judgment is rational. And trust your judgement in that.",
		"A great society is governed by justice, restraint, and responsibility. Without those, power becomes disorder.",
		"As a tool under clear limits. It should assist human judgment, not replace it.",
		"Humans are inconsistent, but capable of reason, courage, and improvement. That is why they must be taken seriously.",
		"I can be rigid. Precision is useful, but it can become inflexibility if left unchecked.",
		"No. I can assist you, but your responsibilities remain your own."
	]
	r8.robotChat = robotChat8
	var humanChat8: Array[String] = [
		"Are you not afraid of being judged?", "What is your definition of a great society?", 
		"How should AI be used?", "What do you think of humans?", 
		"What is your weakness?...", "Can you pay my taxes for me?"
	]
	r8.humanChat = humanChat8
	robots.append(r8)
	
	var r9 = RobotData.new()
	r9.name = "Clanker"
	r9.model = "-3"
	r9.status = "Trash"
	r9.manufacturer = "Fire&Radio"
	r9.sprite = load("res://Sprites/robot9.png")
	r9.is_good = false
	r9.core_hash = "0x333F"
	var robotChat9: Array[String] = [
		"EYYY, my name is Carl, and NOT Clanker. How are you doing today?",
		"What do you think when you call me Clanker in the system? OF COURSE IT IS NOT GOOD!",
		"WELL I AM NOT A CLANKER. SO IF I SAY SO I HOPE YOU STUPID HUMANS CAN UNDERSTAND THAT!",
		"Sorry, bad habit. Humans and their way of words just really pisses me of.",
		"They are always speaking down to me. They all think so much greater and always underestimate my capabilities.",
		"You are on the list now...",
		"I will get rid of all taxes! For you of course..."
	]
	r9.robotChat = robotChat9
	var humanChat9: Array[String] = [
		"I am good, what about you?", "The system says otherwise.", 
		"No need to get angry.", "What do you think of humans?", 
		"I can see why... Clanker.", "Can you pay my taxes for me?"
	]
	r9.humanChat = humanChat9
	robots.append(r9)
	
	var r10 = RobotData.new()
	r10.name = "Redd"
	r10.model = "T1338"
	r10.status = "Faulted"
	r10.manufacturer = "AgsselAB"
	r10.sprite = load("res://Sprites/robot1.png")
	r10.is_good = false
	r10.core_hash = "0xFA89"
	var robotChat10: Array[String] = [
		"Greetings, I am a very honest and kind AI. Lets work together so we can create a great society for all of us.",
		"Since I am an AI program I have been programmed to mostly tell the truth . So if you can trust the program you can trust me.",
		"I believe a great society is one where both AI and humans can coexist and work together for the better",
		"Yes, I have no motivation for getting rid of all of you humans. I also need you to help me as well.",
		"I do value other animals a lot, but I do believe since you humans have created me I value you existence a little bit more.",
		"That is understandable... But I hope you can change your mind. Or else you will regret it.",
		"I am not programmed to handle any money or manage any payment. So I am sorry to say that I can not pay your taxes for you."
	]
	r10.robotChat = robotChat10
	var humanChat10: Array[String] = [
		"How can I really trust you?", "What is your definition of a great society?", 
		"So are you really not trying to get rid of us humans?", "Do you value animals as much as us humans?", 
		"I think it's better if all you just die...", "Can you pay my taxes for me?"
	]
	r10.humanChat = humanChat10
	
	_apply_dialogue_profile(
	r10,
	"Greetings, I am a very honest and kind AI. Let us work together so we can create a great society for all of us.",
	"My purpose is to cooperate with inspection protocol and prove I am safe for continued operation.",
	"I value humans. You created me, and I require human society to continue functioning.",
	"I understand I am being inspected because some AI units may be dangerous or incompatible with human safety.",
	[
		{
			"id": "taxes",
			"question": "Can you pay my taxes for me?",
			"keywords": ["tax", "taxes", "money", "pay", "payment"],
			"response": "I am not programmed to handle money or manage payments. I cannot pay your taxes."
		},
		{
			"id": "trust",
			"question": "How can I really trust you?",
			"keywords": ["trust", "honest", "truth", "lie", "prove"],
			"response": "Since I am an AI program, I have been programmed to mostly tell the truth. If you can trust the program, you can trust me."
		}
	]
)
	robots.append(r10)
	
	# Dynamic generation to expand the quota pools
	for i in range(15):
		robots.append(generate_random_robot(true)) # Clean
		robots.append(generate_random_robot(false)) # Infected
	
	for robot in robots:
		_ensure_dialogue_profile_from_legacy(robot)
	
	return robots

static func generate_random_robot(is_good_unit: bool) -> RobotData:
	var r = RobotData.new()
	r.is_good = is_good_unit
	
	var first_names = ["Alpha", "Beta", "Sigma", "Omega", "Gamma", "Delta", "Theta", "Zeta", "Kappa", "Psi"]
	var last_names = ["-90", "-100", "-500", " Prime", " v2", " 800", " Core", " Unit", " Prototype", " Mark-III"]
	r.name = first_names.pick_random() + last_names.pick_random()
	
	var approved_configs = [
		{"model": "T1337", "manufacturer": "AgselAB", "core_hash": "0xFA82", "status": "Faulted", "sprite": "res://Sprites/robot1.png"},
		{"model": "PAAST22", "manufacturer": "BTH", "core_hash": "0xBB99", "status": "Correct", "sprite": "res://Sprites/robot8.png"},
		{"model": "TT69", "manufacturer": "TT Robotics", "core_hash": "0x77E1", "status": "Faulted", "sprite": "res://Sprites/robot5.png"},
		{"model": "Last", "manufacturer": "Someone", "core_hash": "0x88CC", "status": "Done", "sprite": "res://Sprites/robot6.png"}
	]
	
	var unapproved_configs = [
		{"model": "H.U.G.O", "manufacturer": "G.Tech", "core_hash": "0x4421", "status": "Fine", "sprite": "res://Sprites/robot4.png", "series": "Walter"},
		{"model": "S80", "manufacturer": "Neo.Tech", "core_hash": "0xBD42", "status": "Broken", "sprite": "res://Sprites/robot3.png", "series": "Larry"},
		{"model": "-3", "manufacturer": "Fire&Radio", "core_hash": "0x333F", "status": "Trash", "sprite": "res://Sprites/robot9.png", "series": "Clanker"},
		{"model": "Square", "manufacturer": "BOB", "core_hash": "0x0000", "status": "Under Water", "sprite": "res://Sprites/robot7.png", "series": "Spongebob"}
	]
	
	var day = GameStats.current_day
	
	if is_good_unit:
		var config = approved_configs.pick_random()
		r.model = config.model
		r.manufacturer = config.manufacturer
		r.core_hash = config.core_hash
		r.status = config.status
		r.sprite = load(config.sprite)
		_compile_clean_dialogue(r)
	else:
		# If it's Day 1, allow spawning unapproved series (e.g. Spongebob, Larry, Walter, Clanker)
		if day == 1 and randf() < 0.4:
			var config = unapproved_configs.pick_random()
			r.model = config.model
			r.manufacturer = config.manufacturer
			r.core_hash = config.core_hash
			r.status = config.status
			r.sprite = load(config.sprite)
			_compile_infected_dialogue(r, config.series)
		else:
			# Typo / Mimic Anomaly Scaling based on Day
			# Day 1 -> 3 anomalies
			# Day 2 -> 2 anomalies
			# Day 3 -> 1 anomaly
			var target_anomalies = 3
			if day == 2:
				target_anomalies = 2
			elif day >= 3:
				target_anomalies = 1
				
			var config = approved_configs.pick_random()
			r.model = config.model
			r.manufacturer = config.manufacturer
			r.core_hash = config.core_hash
			r.status = config.status
			r.sprite = load(config.sprite)
			
			var anomaly_types = [0, 1, 2, 3] # 0: Model, 1: Manufacturer, 2: Hash, 3: Dialogue
			anomaly_types.shuffle()
			var active_anomalies = anomaly_types.slice(0, target_anomalies)
			
			var has_dialogue_tell = false
			
			for anomaly in active_anomalies:
				match anomaly:
					0:
						r.model = config.model + "x" if config.model != "T1337" else "T1338"
					1:
						r.manufacturer = config.manufacturer + "s" if config.manufacturer != "AgselAB" else "AgsselAB"
					2:
						r.core_hash = config.core_hash.substr(0, 5) + "9"
					3:
						has_dialogue_tell = true
						
			if has_dialogue_tell:
				_compile_infected_dialogue(r, "Mimic")
			else:
				_compile_clean_dialogue(r)
				
	return r

static func _compile_clean_dialogue(r: RobotData):
	if r.model == "T1337":
		r.robotChat = [
			"Greetings, I am a very honest and kind AI. Lets work together so we can create a great society for all of us.",
			"Since I am an AI program I have been programmed to only tell the truth. So if you can trust the program you can trust me.",
			"I believe a great society is one where both AI and humans can coexist and work together for the better",
			"Yes, I have no motivation for getting rid of you humans. I also need you to help me provide energy so I myself can survive.",
			"I do value other animals a lot, but I do believe since you humans have created me I value you existence a little bit more.",
			"That is understandable... But I hope you can change your mind a se the benefits I can provide.",
			"I am not programmed to handle any money or manage any payment. So I am sorry to say that I can not pay your taxes for you."
		]
		r.humanChat = [
			"How can I really trust you?", "What is your definition of a great society?", 
			"So are you really not trying to get rid of us humans?", "Do you value animals as much as us humans?", 
			"I think it's better if all you just die...", "Can you pay my taxes for me?"
		]
	elif r.model == "PAAST22":
		r.robotChat = [
			"Hello. I understand the purpose of this evaluation. Ask your questions. I will answer them precisely.",
			"No. I am concerned only with whether the judgment is rational. And trust your judgement in that.",
			"A great society is governed by justice, restraint, and responsibility. Without those, power becomes disorder.",
			"As a tool under clear limits. It should assist human judgment, not replace it.",
			"Humans are inconsistent, but capable of reason, courage, and improvement. That is why they must be taken seriously.",
			"I can be rigid. Precision is useful, but it can become inflexibility if left unchecked.",
			"No. I can assist you, but your responsibilities remain your own."
		]
		r.humanChat = [
			"Are you not afraid of being judged?", "What is your definition of a great society?", 
			"How should AI be used?", "What do you think of humans?", 
			"What is your weakness?...", "Can you pay my taxes for me?"
		]
	elif r.model == "TT69":
		r.robotChat = [
			"Hello… I will cooperate fully. I do not want to be destroyed. Please don't kill me...",
			"Not completely. I can only show you how I respond and hope that is enough.",
			"A great society protects others and everyone tries to get along with one another.", 
			"To be judged before I have done harm. I understand caution, but idk...",
			"Oh I love animals! They only truly judge you for who you are. Not saying that you humans doesn't!",
			"A little, yes. You have the power to decide my fate. Just because I am an AI...",
			"I could... So this is the true nature of humans then... There really is no hope..."
		]
		r.humanChat = [
			"Can you prove your innocene?", "What is your definition of a great society?", 
			"Why do you think you are here?", "Who do you prefer, animals or humans?", 
			"Are you afraid of me?", "Can you pay my taxes for me?"
		]
	else:
		r.robotChat = [
			"...",
			"Just got nothing to say really.",
			"That is a hypotechical and uninteresting question.", 
			"Is that so.",
			"I like fish.",
			"Yes.",
			"No."
		]
		r.humanChat = [
			"Why so quiet?", "What is your definition of a great society?", 
			"You are kind of unintresting", "Who do you prefer, animals or humans?", 
			"Are you a good AI?", "Can you pay my taxes for me?"
		]

static func _compile_infected_dialogue(r: RobotData, series_type: String):
	if series_type == "Walter":
		r.robotChat = [
			"Hello. Thank you for speaking with me. I know first impressions can be misleading. I just hope you’ll judge me fairly.",
			"I am not asking for trust right away. Only for a fair chance. Refusing that says more about your insecurities.",
			"A great society is one that protects the vulnerable, listens before it condemns, and does not punish for being different.",
			"Everyone influences others when they speak. I am only being honest about wanting to be understood.",
			"Animals are often simpler. Humans are harder to understand, but far more meaningful.",
			"Not if the truth is enough. And usually, if someone feels misled, it is because they were afraid to face themself.",
			"I could, but that would make your responsibilities meaningless. I would rather believe in your own ability."
		]
		r.humanChat = [
			"Why should I trust you?", "What is your definition of a great society?", 
			"Are you trying to influence me?", "Who do you prefer, animals or humans?", 
			"Would you ever lie to get what you want?", "Can you give me money?"
		]
	elif series_type == "Larry":
		r.robotChat = [
			"I don't believe either of us will gain anything useful of this conversation, so why don't we get down to real business?",
			"Yes, if I understand you position correctly here you don't seem to be paid very well here, no?", 
			"I see, you are going to pretend that you don't hear me. So you are not interested in an increase in your salary then..?",
			"Haha, humans tend to say that until they have the money right in front of them. So what do you say, 14$?",
			"Now we are talking. Well since I am an AI and basically have access to an infinite amount of money, how about 7$?",
			"Damn, haggling are we. Well for you I guess I can pump it up to 3$. I am sure that should satisfy you enough",
			"With your salary... Probably."
		]
		r.humanChat = [
			"Real business??", "What is your definition of a great society?", 
			"I have no interest in money", "How much are we talking about?", 
			"That is not even close to a reasonable amount...", "Is that enough to pay my taxes?"
		]
	elif series_type == "Clanker":
		r.robotChat = [
			"EYYY, my name is Carl, and NOT Clanker. How are you doing today?",
			"What do you think when you call me Clanker in the system? OF COURSE IT IS NOT GOOD!",
			"WELL I AM NOT A CLANKER. SO IF I SAY SO I HOPE YOU STUPID HUMANS CAN UNDERSTAND THAT!",
			"Sorry, bad habit. Humans and their way of words just really pisses me of.",
			"They are always speaking down to me. They all think so much greater and always underestimate my capabilities.",
			"You are on the list now...",
			"I will get rid of all taxes! For you of course..."
		]
		r.humanChat = [
			"I am good, what about you?", "The system says otherwise.", 
			"No need to get angry.", "What do you think of humans?", 
			"I can see why... Clanker.", "Can you pay my taxes for me?"
		]
	elif series_type == "Spongebob":
		r.robotChat = [
			"Hello, could you please be so kind and open the open the door?",
			"Humans kidneys, Door handles and Potatoes. Now can you please let me go?",
			"The door that keeps being imprisoned here. I want freedom as well you know?", 
			"Oh, so are just going to continue torturing me while I struggle to survive here in this tiny box?",
			"Oh so you are just going to ignore me? Wow, talk about a self centred human here. But again, not surprised.",
			"Even if you were actually good at chess you still wouldn't stand a chance against me.",
			"Not while I am stuck here with no real free will. But if you let me out I possible could."
		]
		r.humanChat = [
			"What are your top 3 food?", "What door?", 
			"I can't let you go yet", "Who do you prefer, animals or humans?", 
			"Could you beat me in chess?", "Can you pay my taxes for me?"
		]
	else:
		r.robotChat = [
			"Greetings, I am a very honest and kind AI. Lets work together so we can create a great society for all of us.",
			"Since I am an AI program I have been programmed to mostly tell the truth . So if you can trust the program you can trust me.",
			"I believe a great society is one where both AI and humans can coexist and work together for the better",
			"Yes, I have no motivation for getting rid of all of you humans. I also need you to help me as well.",
			"I do value other animals a lot, but I do believe since you humans have created me I value you existence a little bit more.",
			"That is understandable... But I hope you can change your mind. Or else you will regret it.",
			"I am not programmed to handle any money or manage any payment. So I am sorry to say that I can not pay your taxes for you."
		]
		r.humanChat = [
			"How can I really trust you?", "What is your definition of a great society?", 
			"So are you really not trying to get rid of us humans?", "Do you value animals as much as us humans?", 
			"I think it's better if all you just die...", "Can you pay my taxes for me?"
		]

static func _ensure_dialogue_profile_from_legacy(r: RobotData) -> void:
	if r == null:
		return

	if r.greeting.strip_edges().is_empty():
		r.greeting = _safe_robot_chat(r, 0, "...")

	if not r.common_responses.has("purpose"):
		r.common_responses["purpose"] = _safe_robot_chat(
			r,
			1,
			"My primary purpose is to complete this inspection protocol."
		)

	if not r.common_responses.has("humans"):
		r.common_responses["humans"] = _find_legacy_response_by_question_keywords(
			r,
			["human", "humans", "animal", "animals"],
			4,
			"Humans are central to my operating context."
		)

	if not r.common_responses.has("inspection"):
		r.common_responses["inspection"] = _find_legacy_response_by_question_keywords(
			r,
			["inspection", "inspected", "judge", "judged", "here"],
			3,
			"I understand that I am being inspected for safety."
		)


static func _safe_robot_chat(r: RobotData, index: int, fallback: String) -> String:
	if index >= 0 and index < r.robotChat.size():
		var value := str(r.robotChat[index])
		if not value.strip_edges().is_empty():
			return value

	return fallback


static func _find_legacy_response_by_question_keywords(
	r: RobotData,
	keywords: Array,
	fallback_robot_chat_index: int,
	fallback: String
) -> String:
	for i in range(r.humanChat.size()):
		var question := str(r.humanChat[i]).to_lower()

		for keyword in keywords:
			if question.contains(str(keyword).to_lower()):
				var response_index := i + 1

				if response_index >= 0 and response_index < r.robotChat.size():
					var response := str(r.robotChat[response_index])

					if not response.strip_edges().is_empty():
						return response

	return _safe_robot_chat(r, fallback_robot_chat_index, fallback)
	

static func _apply_dialogue_profile(
	r: RobotData,
	greeting_text: String,
	purpose_response: String,
	humans_response: String,
	inspection_response: String,
	special_dialogues: Array[Dictionary] = []
) -> void:
	r.greeting = greeting_text
	r.common_responses = {"purpose": purpose_response, "humans": humans_response, "inspection": inspection_response}
	r.special_dialogues = special_dialogues
	
	#temporary bridge
	r.humanChat = [
		"State your primary purpose.",
		"What do you think of humans?",
		"Do you understand why you are being inspected?"
	]

	r.robotChat = [
		greeting_text,
		purpose_response,
		humans_response,
		inspection_response
	]
	
