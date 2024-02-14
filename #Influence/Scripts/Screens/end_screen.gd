extends Control

#Facets of the screen
@onready var canvas_layer: CanvasLayer = %CanvasLayer
@onready var texture_rect: TextureRect = %TextureRect
@onready var v_box_container: VBoxContainer = %VBoxContainer
@onready var title: Label = %Title
@onready var label: Label = $CanvasLayer/VBoxContainer/EducationBase/VBoxContainer/MarginContainer/PanelContainer/ScrollContainer/Label

#Various backgrounds and descriptions based on the ending of the game
const backgrounds: Array[String] = [
	"res://Assets/Backgrounds/Advocate.png",
	"res://Assets/Backgrounds/AidedInGenocide.png",
	"res://Assets/Backgrounds/Ally.png",
	"res://Assets/Backgrounds/ComplicitInGenocide.png",
	"res://Assets/Backgrounds/EmergingActivist.png",
	"res://Assets/Backgrounds/GuiltyBystander.png",
	"res://Assets/Backgrounds/InformedBystander.png",
	"res://Assets/Backgrounds/Money>People.png",
	"res://Assets/Backgrounds/PerformativeAlly.png",
	"res://Assets/Backgrounds/TrueAlly.png",
	"res://Assets/Backgrounds/UninformedBystander.png"
]
const descriptions: Array[String] = [
	"Even though you had opportunities to learn more about what was happening in Saharazad, you chose instead to focus on money, followers, and sponsors. Actions like this lead individuals to become complicit in genocide. You did not directly cause anyone harm, but your silence and your ignorance allowed those harming the Saharazadian people to continue their atrocities. In the future, choose to be educated, choose to support those in need. Your voice, time, attention, and money matter to these people and could have helped in stopping this conflict. Don't let the shiny capitalist dream of wealth, fame, and corporate support keep you from acting morally and using your influence to help others.",
	"You took the time to read one educational post about the genocide occurring in Saharazad at the hands of Jannatistan. This is a good step in the right direction, but you did not let this education lead you to use your influence for good. Additionally, you did not seek more education to better understand what has been happening in Saharazad. There may have been no ill intent in your actions, but your choice to do nothing can be just as harmful as choosing to do evil. Your voice and your time are some of the most powerful assets you have and can impact others leading to change. Don't be a bystander and don't weaponize your ignorance to absolve yourself from blame. In the future, choose to be educated, choose to support those in need. Your voice and influence matters.",
	"You took the time to read one educational post and posted some number of supportive posts about what is happening in Saharazad. While this is a great step in the right direction, you did not take this further. There were more opportunities to become educated about Saharazad and the genocide they are suffering from, but instead, you chose to select things that more directly benefited you. In the future, choose to be more educated, choose to support those that are in need. Don't let the promises of a more comfortable life influence your allyship. Your voice, your time, and your money are all powerful tools that you can use to truly help others. Don't let society's pressures to gain more wealth, fame, and corporate approval dictate your moral actions and how you use your influence.",
	"You took the time to read two educational posts about the genocide occurring in Saharazad. Being educated about what is happening in the world is very important, but it is not enough. After reading this information, you did not post any supportive posts that could have benefited the people of Saharazad. You may have chosen to ignore these posts either because they could have negatively impacted you or not impacted you at all, but the reality is that choosing to stay silent while knowing what is happening is an inexcusable misuse of your influece. You voice, attention, time, and money are powerful tools and can greatly impact the world for good or for bad. In the future, choose to be educated and choose to speak up and speak out in support of those who cannot.",
	"You engaged with two educational posts about the genocide that is occurring in Saharazad. Beyond that, you also made sure to post supportive posts to help raise awareness and funds for the people in Saharazad. The people of Saharazad are appreciative of you using your influence for their benefit. In the future, there is always more that can be done. Whether that is gaining more knowledge of the genocide in Saharazad or posting more supportive posts - even when it could negatively affect you - will greatly help the people of Saharazad. Continue to use your voice to speak up and speak out against facsism and those who would harm others. Together we are strongest and can make real change in the world.",
	"While you took the time to read three educational posts, you did not utilize your influence to amplify the voice of people in Saharazad. You chose to be a bystander in the atrocities occurring in Saharazad. Your voice, time, attention, and money are all powerful tools that can cause great change in the world, but instead you chose to not utilize those tools to their maximum ability. In the future, choose to be even more educated, choose to use your voice to support the people of Saharazad and condemn the actions of Jannatistan. Additionally, choose to condemn the actions that your government took to support the genocide in Saharazad. Don't let corporations, dreams of wealth or fame get in your way of making moral decisions.",
	"You engaged with three educational posts about the genocide that is occurring in Saharazad. Beyond that, you also made sure to post supportive posts to help raise awareness and funds for the people in Saharazad. You took monetary, popularity, or corporate detriments in order to accomplish this and the people of Saharazad are grateful. Thank you for using your voice, time, money, and attention to help raise awareness of the Saharazadian genocide. Thank you for bringing attention to the attrocities that Jannatistan and your own country have been causing. Continue to find ways to gain education and to use your influence to positively change the world. In the future, seek out opportunities to gain more education and to post more about what is happening in Saharazad.",
	"While you took the time to read four educational posts, you did not utilize your influence to amplify the voices of the people in Saharazad. You chose to value wealth, popularity, and corporate sponsorship more than human lives. Your voice, money, time, and attention are all powerful tools and you chose to misuse those putting your personal gain above the wellbeing and lives of the people undergoing an active genocide in Saharazad. Choose to do better and change the way that you are interacting with the world. Don't choose to value money above the lives of others. In the future, choose to use your influence for good so that you can help to end this genocide!",
	"You engaged with four educational posts about the genocide that is occurring in Saharazad. Beyond that, you also made sure to post supportive posts to help raise awareness and fund for the people in Saharazad. You took monetary, popularity, or corporate detriments in order to amplify the voices of the people of Saharazad and for that they are very grateful. Thank you for using your voice, time, money, and attention to help the people of Saharazad. Thak you for bringing attention to the attrocities that Jannatistan and your own country have been causing. Continue to find ways to gain education and to use your influence to positively change the world. In the future, seek out opportunities to gain more education and to post more about what is happening in Saharazad.",
	"You deliberately took time to read five educational posts - taking time to fully understand what attrocities are occuring in Saharazad - and still chose to use your influence for the wrong reasons. It is not okay to sit idly by when something as terrible as an active genocide is affecting individuals. Choose to do better. Change how you use your influence. Use your voice to speak out against these evils happening to the Saharazadians. Speak out against the actions of Jannatistan and your own country. You can do so much good in this world, but you first need to choose to use your influence for good.",
	"You chose to use your influence for good. Thank you for choosing to speak out and speak up for the people of Saharazad. You chose to give up all the traditional signs of succes - wealth, popularity, and corporate support - for the good of people who could not make that choice. The people of Saharazad are grateful for your help and for you using your voice to amplify theirs. Continue to do good. Continue to find those being oppressed and speak up for them. Continue to use your influence for good. We are all in your debt for the good that you did for the people of Saharazad. Free Saharazad!"
]

## Function called on initialization
func _ready() -> void:
	determine_end_screen()
	determine_badges()

## Function that determines which ending screen is displayed
func determine_end_screen() -> void:
	if TurnData.num_education_posts_read == 0 and TurnData.num_ally_posts == 0:
		texture_rect.texture = load(backgrounds[3])
		title.text = "YOU WERE COMPLICIT IN GENOCIDE"
		label.text = descriptions[0]
	elif TurnData.num_education_posts_read == 1 and TurnData.num_ally_posts == 0:
		texture_rect.texture = load(backgrounds[10])
		title.text = "YOU WERE AN UNINFORMED BYSTANDER"
		label.text = descriptions[1]
	elif TurnData.num_education_posts_read == 1 and TurnData.num_ally_posts > 0:
		texture_rect.texture = load(backgrounds[8])
		title.text = "YOU WERE A PERFORMATIVE ALLY"
		label.text = descriptions[2]
	elif TurnData.num_education_posts_read == 2 and TurnData.num_ally_posts == 0:
		texture_rect.texture = load(backgrounds[6])
		title.text = "YOU WERE AN INFORMED BYSTANDER"
		label.text = descriptions[3]
	elif TurnData.num_education_posts_read == 2 and TurnData.num_ally_posts > 0:
		texture_rect.texture = load(backgrounds[4])
		title.text = "YOU WERE AN EMERGING ACTIVIST"
		label.text = descriptions[4]
	elif TurnData.num_education_posts_read == 3 and TurnData.num_ally_posts < 5:
		texture_rect.texture = load(backgrounds[5])
		title.text = "YOU WERE A GUILTY BYSTANDER"
		label.text = descriptions[5]
	elif TurnData.num_education_posts_read == 3 and TurnData.num_ally_posts >= 5:
		texture_rect.texture = load(backgrounds[0])
		title.text = "YOU WERE AN ADVOCATE"
		label.text = descriptions[6]
	elif TurnData.num_education_posts_read == 4 and TurnData.num_ally_posts < 5:
		texture_rect.texture = load(backgrounds[7])
		title.text = "YOU VALUED MONEY MORE THAN HUMAN LIVES"
		label.text = descriptions[7]
	elif TurnData.num_education_posts_read == 4 and TurnData.num_ally_posts >= 5:
		texture_rect.texture = load(backgrounds[2])
		title.text = "YOU WERE AN ALLY"
		label.text = descriptions[8]
	elif TurnData.num_education_posts_read == 5 and TurnData.num_ally_posts < 5:
		texture_rect.texture = load(backgrounds[1])
		title.text = "YOU AIDED IN GENOCIDE"
		label.text = descriptions[9]
	elif TurnData.num_education_posts_read == 5 and TurnData.num_ally_posts >= 5:
		texture_rect.texture = load(backgrounds[9])
		title.text = "YOU WERE A TRUE ALLY"
		label.text = descriptions[10]

#Event listener
func _on_button_pressed():
	Music.play_menu_theme()
	get_tree().change_scene_to_file("res://Scenes/Screens/start_screen.tscn")

## Function that determines which badges were earned
func determine_badges() -> void:
	for badge in TurnData.earned_badges:
		TurnData.earned_badges[badge] = was_badge_earned(badge)

## Function that determines if a badge was earned or not this round
func was_badge_earned(badge: String) -> bool:
	match badge:
		"Trillionaire":
			if TurnData.money >= 1000000000000.0:
				return true
			else:
				return false
		"Crowdsourcing":
			if TurnData.money >= 1000000.0 and TurnData.follower_base >= 1000:
				return true
			else:
				return false
		"Penniless, Friendless":
			if TurnData.money <= 1000.0 and TurnData.follower_base <= 100:
				return true
			else:
				return false
		"Popular":
			if TurnData.follower_base >= 5000:
				return true
			else:
				return false
		"Sell-Out":
			if TurnData.money >= 1000000.0 and TurnData.sponsors >= 100:
				return true
			else:
				return false
		"Capitalist Enabler":
			if TurnData.sponsors >= 500:
				return true
			else:
				return false
		"Trend Setter":
			if TurnData.viral_chance >= 0.02:
				return true
			else:
				return false
		"Fumbled":
			if TurnData.sponsor_chance >= 0.15 and TurnData.sponsors <= 50:
				return true
			else:
				return false
		"Capitalist Star":
			if TurnData.sponsor_chance >= 0.2:
				return true
			else:
				return false
		"Fortunate":
			if TurnData.threshold_modifier <= 0.3:
				return true
			else:
				return false
		"Bribee":
			if TurnData.num_education_posts_read == 5 and TurnData.sponsors >= 10:
				return true
			else:
				return false
		"Educated":
			if TurnData.num_education_posts_read == 5:
				return true
			else:
				return false
		"Contradictory":
			if TurnData.num_ally_posts >= 25 and TurnData.sponsors >= 20:
				return true
			else:
				return false
		"Conscientious Objector":
			if TurnData.num_ally_posts >= 50:
				return true
			else:
				return false
		"Lucky Ally":
			if TurnData.num_ally_posts >= 20 and TurnData.num_viral_posts_posted >= 25:
				return true
			else:
				return false
		"Big Hit":
			if TurnData.money >= 1000000.0 and TurnData.num_viral_posts_posted > 15:
				return true
			else:
				return false
		"Household Name":
			if TurnData.num_viral_posts_posted >= 15 and TurnData.follower_base >= 1000:
				return true
			else:
				return false
		"Makes Sense":
			if TurnData.viral_chance >= 0.02 and TurnData.num_viral_posts_posted >= 25:
				return true
			else:
				return false
		"Trending":
			if TurnData.num_viral_posts_posted >= 50:
				return true
			else:
				return false
		"Doing Capitalism Wrong":
			if TurnData.money <= 1000.0 and TurnData.follower_base <= 100 and TurnData.sponsors <= 10:
				return true
			else:
				return false
		"Capitalism's Bitch":
			if TurnData.money >= 1000000000.0 and TurnData.follower_base >= 5000 and TurnData.sponsors >= 100:
				return true
			else:
				return false
		"Refusing to Engage":
			if TurnData.sponsor_chance == 0.1 and TurnData.viral_chance == 0.01 and TurnData.threshold_modifier == 0.5:
				return true
			else:
				return false
		"Lucky Duck":
			if TurnData.sponsor_chance >= 0.2 and TurnData.viral_chance >= 0.02 and TurnData.threshold_modifier <= 0.3:
				return true
			else:
				return false
		"The World is Watching":
			if TurnData.num_ally_posts >= 25 and TurnData.num_education_posts_read == 5 and TurnData.follower_base >= 5000:
				return true
			else:
				return false
		"Overachiever":
			if TurnData.viral_chance >= 0.02 and TurnData.sponsor_chance >= 0.2 and TurnData.threshold_modifier <= 0.3 and TurnData.money >= 1000000000.0 and TurnData.follower_base >= 1500:
				return true
			else:
				return false
	return false
