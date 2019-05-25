#!/bin/bash

###
# RACE LINKS
###

# trim the string
#races=$(curl -s https://www.dndbeyond.com/characters/races | grep -n -A3000 -m1 dragonborn | grep -B3000 -m1 "Sword Coast Adve" | grep href | grep -o '".*" ' | sed 's/"//g')
races=$(cat raceLinks | sed 's/ /\n/g')

#echo $races

i=1
for url in $races; do
	# create a file for convenience
    # echo "https://www.dndbeyond.com$url" >> raceLinks

	# curl -s $url >> res/race$i

###
# RACE DATA
###

	# sleep 1
    # rawInfo=$(curl -s https://www.dndbeyond.com$url | grep -m1 -A2000 html | grep -m1 -A2000 RaceDetails | grep -m1 -B2000 Comment | grep -m1 -A2000 h2)

    # raceDescription=$(echo $rawInfo | grep -m1 -B1000 ' Names</h2>' | grep -v id=\" | sed 's/[</]span>//g' | sed 's/[</]p>//g' | sed 's/[<>]//g')

###
# ATTRIBUTES
###

	# get ability score improvement of race not subrace
	# negative values will need to be adjusted by hand
 
	#raceAbilityBonuses=$(echo $rawInfo | grep 'increases by' | awk '{$1=$1};1' | sed 's/.our//g')
	echo ''
	echo race$i
	echo ''
	#raceAbilityBonuses=$(cat res/race$i | grep -m1 -A3000 'html' | grep -m1 -A3000 'RaceDetails' | grep -m1 -B2000 'Comment' | grep -m1 -A2000 'h2' | grep -m1 -A1 '<h4>Ability Score Increase</h4>' | tail -1 | sed 's/[</]span>//g' | sed 's/[</]p//g' | sed 's/[<>]//g' | awk '{$1=$1};1' | sed 's/.our //g' | sed 's/ score increases by\|\|, and\|\| score decrease| sed 's/.our //g' | sed 's/ score increases by\|\|, and\|\| score decreases by\|\|\.//g' | sed ':a;N;$!ba;s/\n\n//g'raceAbilityBonuses=$( cat res/race$i | grep -m1 -A3000 'RaceDetails' | grep -m1 -B3000 'Comment' | grep -m1 -A3000 'h2' | grep \A1 '<h4>Ability Score Increase<\h4>' | awk'{$1=$1};1' |   )raceAbilityBonuses=$( cat res/race$i | grep -m1 -A3000 'html' | grep -m1 -A3000 'RaceDetails' | grep -m1 -B2000 'Comment' | grep -m1 -A2000 'h2' | grep -A1 '<h4>Ability Score Increase</h4>' | awk '{$1=$1};1' | sed 's/<h4.*\|\|--//g' | sed 's/[</]p//g' | sed 's/[<>]//g' | awk '{$1=$1};1' | sed 's/.our //g' | sed 's/ score increases by\|\|, and\|\| score decreases by\|\|\.//g' | sed ':a;N;$!ba;s/\n\n//g' )
	
	raceAbilityBonuses=$( cat res/race$i | grep -m1 -A3000 'RaceDetails' | grep -m1 -B2000 'Comment' | grep -m1 -A2000 'h2' | grep -A1 '<h4>Ability Score Increase</h4>' | awk '{$1=$1};1' | sed 's/<h4.*\|\|--//g' |  sed 's/[</]span>//g' | sed 's/[</]p//g' | sed 's/[<>]//g' | awk '{$1=$1};1' | sed 's/.our //g' | sed 's/ score increases by\|\|, and\|\| score decreases by\|\|\.//g' | sed ':a;N;$!ba;s/\n\n//g' | grep . | sed 's/ //g' )

	raceText=$(cat res/race$i | grep -m1 -B2000 'static-container-footer' | grep -m1 -A2000 'h2' )
	raceNames=$(echo -e "$raceText" | sed 's/<p>/\n/g' | sed 's/<h3/\n<h3/g' | sed 's/<\/h3>/<\/h3>\n/g' | grep 'h3' | sed 's/<.*\">//g' | sed 's/<\/h3>//g')

#	echo $raceText
#	echo $raceNames

	# TODO: Get subrace name,
	# TODO: Get parent race,
	# TODO: Get description,
	# TODO: Get proficiencies,
	# TODO: Get language options,
	# TODO: Get racial traits

	#echo Race Skill Bonuses:
	#echo $raceAbilityBonuses
	#echo ''

	subraceCount=1
	for subraceBonuses in $raceAbilityBonuses; do

###
# RACE NAMES
###

		# first subrace is parent
		echo Subrace$subraceCount
		# try to get subrace name
		if [[ $i == 1 ]]; then
			echo Dragonborn
		else
			echo -e "$raceNames"
		fi

		str=0
		dex=0
		con=0
		int=0
		wis=0
		cha=0
		# number of stats that can be increased by one
		increases=0
		# can improve these stats by one instead of others
		statChoices=""
		
#	echo $subraceBonuses

		if [[ $subraceBonuses == *"scores"* ]]; then
			if [[ $subraceBonuses == *"each"* ]]; then
				# Means this is human with no subclass
				# And we don`t count it since it is already in the json
				#echo $subraceBonuses This is Human
				str=1
				dex=1
				con=1
				int=1
				wis=1
				cha=1
				# possible single stat increases
				# leftover stat points
			fi
			if [[ $subraceBonuses == *"choice"* ]]; then
				# Has bonuses to other abilities
				# Can choose any ablity to improve by 1
				# Needs a new field added to json
				if [[ $subraceBonuses == *"ne"* ]]; then
					#echo $subraceBonuses This can improve ONE score by 1
					if [[ $subraceBonuses == *"Strength"* ]]; then
						str=$(echo $subraceBonuses | sed 's/.*bothincreaseby//g' | head -c 1)
					fi
					if [[ $subraceBonuses == *"Dexterity"* ]]; then
						dex=$(echo $subraceBonuses | sed 's/.*bothincreaseby//g' | head -c 1)
					fi
					if [[ $subraceBonuses == *"Constitution"* ]]; then
						con=$(echo $subraceBonuses | sed 's/.*bothincreaseby//g' | head -c 1)
					fi
					if [[ $subraceBonuses == *"Intelligence"* ]]; then
						int=$(echo $subraceBonuses | sed 's/.*bothincreaseby//g' | head -c 1)
					fi
					if [[ $subraceBonuses == *"Wisdom"* ]]; then
						wis=$(echo $subraceBonuses | sed 's/.*bothincreaseby//g' | head -c 1)
					fi
					if [[ $subraceBonuses == *"Charisma"* ]]; then
						cha=$(echo $subraceBonuses | sed 's/.*bothincreaseby//g' | head -c 1)
					fi
					let increases+=1
				fi
				if [[ $subraceBonuses == *"wo"* ]]; then
					#echo $subraceBonuses This can improve TWO scores by 1
					if [[ $subraceBonuses == *"Strength"* ]]; then
						str=$(echo $subraceBonuses | sed 's/Strength//g' | head -c 1)
						subraceBonuses=$(echo $subraceBonuses | sed 's/Strength.//g')
					fi
					if [[ $subraceBonuses == *"Dexterity"* ]]; then
						dex=$(echo $subraceBonuses | sed 's/Dexterity//g' | head -c 1)
						subraceBonuses=$(echo $subraceBonuses | sed 's/Dexterity.//g')
					fi
					if [[ $subraceBonuses == *"Constitution"* ]]; then
						con=$(echo $subraceBonuses | sed 's/Constitution//g' | head -c 1)
						subraceBonuses=$(echo $subraceBonuses | sed 's/Constitution.//g')
					fi
					if [[ $subraceBonuses == *"Intelligence"* ]]; then
						int=$(echo $subraceBonuses | sed 's/Intelligence//g' | head -c 1)
						subraceBonuses=$(echo $subraceBonuses | sed 's/Intelligence.//g')
					fi
					if [[ $subraceBonuses == *"Wisdom"* ]]; then
						wis=$(echo $subraceBonuses | sed 's/Wisdom//g' | head -c 1)
						subraceBonuses=$(echo $subraceBonuses | sed 's/Wisdom.//g')
					fi
					if [[ $subraceBonuses == *"Charisma"* ]]; then
						cha=$(echo $subraceBonuses | sed 's/Charisma//g' | head -c 1)
						subraceBonuses=$(echo $subraceBonuses | sed 's/Charisma.//g')
					fi
					let increases+=2
				fi
			fi
			if [[ $subraceBonuses == *"either"* ]]; then
				# Has boenuses to abilities
				# Allows to choose one ability out of two to add +1 bonus
				# Needs a json field
				#echo $subraceBonuses This can choose one out of two
					if [[ $subraceBonuses == *"Strength"* ]]; then
						str=$(echo $subraceBonuses | sed 's/.*increaseby//g' | head -c 1)
						statChoices="$statChoices str"
					fi
					if [[ $subraceBonuses == *"Dexterity"* ]]; then
						dex=$(echo $subraceBonuses | sed 's/.*increaseby//g' | head -c 1)
						statChoices="$statChoices dex"
					fi
					if [[ $subraceBonuses == *"Constitution"* ]]; then
						con=$(echo $subraceBonuses | sed 's/.*increaseby//g' | head -c 1)	
						statChoices="$statChoices con"
					fi
					if [[ $subraceBonuses == *"Intelligence"* ]]; then
						int=$(echo $subraceBonuses | sed 's/.*increaseby//g' | head -c 1)
						statChoices="$statChoices int"
					fi
					if [[ $subraceBonuses == *"Wisdom"* ]]; then
						wis=$(echo $subraceBonuses | sed 's/.*increaseby//g' | head -c 1)
						statChoices=$(echo $statChoices wis)
					fi
					if [[ $subraceBonuses == *"Charisma"* ]]; then
						cha=$(echo $subraceBonuses | sed 's/.*increaseby//g' | head -c 1)
						statChoices=$(echo $statChoices cha)
					fi
					let increases+=1
			fi
		else
			if [[ $subraceBonuses == *"Strength"* ]]; then
				str=$(echo $subraceBonuses | sed 's/Strength//g' | head -c 1)
				subraceBonuses=$(echo $subraceBonuses | sed 's/Strength.//g')
			fi
			if [[ $subraceBonuses == *"Dexterity"* ]]; then
				dex=$(echo $subraceBonuses | sed 's/Dexterity//g' | head -c 1)
				subraceBonuses=$(echo $subraceBonuses | sed 's/Dexterity.//g')
			fi
			if [[ $subraceBonuses == *"Constitution"* ]]; then
				con=$(echo $subraceBonuses | sed 's/Constitution//g' | head -c 1)
				subraceBonuses=$(echo $subraceBonuses | sed 's/Constitution.//g')
			fi
			if [[ $subraceBonuses == *"Intelligence"* ]]; then
				int=$(echo $subraceBonuses | sed 's/Intelligence//g' | head -c 1)
				subraceBonuses=$(echo $subraceBonuses | sed 's/Intelligence.//g')
			fi
			if [[ $subraceBonuses == *"Wisdom"* ]]; then
				wis=$(echo $subraceBonuses | sed 's/Wisdom//g' | head -c 1)
				subraceBonuses=$(echo $subraceBonuses | sed 's/Wisdom.//g')
			fi
			if [[ $subraceBonuses == *"Charisma"* ]]; then
				cha=$(echo $subraceBonuses | sed 's/Charisma//g' | head -c 1)
				subraceBonuses=$(echo $subraceBonuses | sed 's/Charisma.//g')
			fi
		fi

		subraceBonuses=[$str,$dex,$con,$int,$wis,$cha]
		echo $subraceBonuses
		echo $increases
		echo $statChoices

		let subraceCount+=1
	done




###
# JSON
###
	# race
#	echo '"name": "$raceName",'
#	echo '"speed": 30,' ## no its not e.g. dwarves are slower
#	echo '"ability_bonuses": $raceAbilityBonuses,'
#	echo '"alignment": "",'
#	echo '"age": "",'
#	echo '"size": "",'
#	echo '"size_description: "",'
#	echo '"starting_proficiencies": [$startingProficiencies],'
#	echo '"starting_proficiency_options": {'
#	echo '$startingProficiencyOptions'
#	echo '},'
#	echo '"languages": ['
#	echo '$raceLanguages'
#	echo '],'
#	echo '"language_options": {'
#	echo '$languageOptions'
#	echo '},'
#	echo '"language_description": "$languageDescription"'
#	echo '"traits": ['
#	echo '$traits'
#	echo '],'
#	echo '"trait_options": {'
#	echo '$traitOptions'
#	echo '},'
#	echo '"subraces": [$subRacesList]'

    let i+=1
done
