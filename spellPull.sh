#!/bin/bash

curl -s 'https://www.dnd-spells.com/spells' | grep href | grep title | grep -v target | grep -f ~/Programming/DND_Helper/SpellsMissingFromHandbook.txt | grep -o '".*" ' | sed 's/"//g' > links
curl -s 'https://www.dnd-spells.com/spells' | grep -A 10 -e \<td\>Elemental -e \<td\>Xanathars | grep href | grep title | grep -v target | grep -o '".*" ' | sed 's/"//g' >> links

for i in $(cat links); do
    curl -s $i > currentSpell

    # Get Attributes

    # Level
    level=$(cat currentSpell | grep '<strong>' | grep : | sed 's/.*<strong>//g' | sed 's/<\/strong>.*//g' | tail -5 | head -1 | sed 's/ //g')
    if [[ $level == "Cantrip" ]]; then
        level=0
    fi

    # Casting time
    castingTime=$(cat currentSpell | grep '<strong>' | grep : | sed 's/.*<strong>//g' | sed 's/<\/strong>.*//g' | tail -4 | head -1)

    # Range
    range=$(cat currentSpell | grep '<strong>' | grep : | sed 's/.*<strong>//g' | sed 's/<\/strong>.*//g' | tail -3 | head -1)

    # Requirments
    requirments=$(cat currentSpell | grep '<strong>' | grep : | sed 's/.*<strong>//g' | sed 's/<\/strong>.*//g' | tail -2 | head -1 | sed 's/ (.*)//g' | sed 's/ //g' | sed 's/,/",\n"/g' )

    # Materials
    materials=$(cat currentSpell | grep '<strong>' | grep : | sed 's/.*<strong>//g' | sed 's/<\/strong>.*//g' | tail -2 | head -1)
    if [[ $materials == *"("* ]]; then
    materials=$(echo $materials | sed 's/(a/(A/g' | sed 's/.*(//g' | sed 's/)//g')
    else
    materials=""
    fi

    # Duration
    duration=$(cat currentSpell | grep '<strong>' | grep : | sed 's/.*<strong>//g' | sed 's/<\/strong>.*//g' | tail -1 | head -1)
    if [[ $duration == *"Concentration"* ]]; then
    concentration=yes
    duration=$(echo $duration | sed 's/Concentration, //g' | sed 's/up/Up/g')
    else
    concentration=no
    fi

    # get higher level
    higherLevel=$(cat currentSpell | grep 'When you cast this spell using a spell slot of' | sed 's/.*When/When/g' | sed 's/\r//g')

    # Get school
    school=$(cat currentSpell | grep -m1 '<p>' | sed 's/.* a //g' | sed 's/ spell.*//g')

    # Get name
    name=$(cat currentSpell | grep -m1 '<p>' | sed 's/.*<p>//g' | sed 's/,.*//g')
    if [[ $name == *"(Ritual)"* ]]; then
        ritual=yes
        name=$(echo $name | sed 's/ (.*)//g')
    else
        ritual=no
    fi

    # Get desription
    description=$(cat currentSpell | grep -A1 '<br />' | grep -o '.*\.' | grep -v '<.*' | awk '{$1=$1};1' | sed ':a;N;$!ba;s/\n/",\n"/g')

    # get classes
    classes=$(cat currentSpell | grep -A12 '                A' | grep spells/class | sed 's/.*">//g' | sed 's/<.*//g' | sed ':a;N;$!ba;s/\n/"\n},\n{\n"name": "/g')

    # get page and book
    page=$(cat currentSpell | grep Page: | sed 's/.*Page: //g' | sed 's/<\/p>//g')
    if [[ $page == *"Handbook"* ]]; then
        page="phb $(echo $page | sed 's/Pl.*//g' | awk '{$1=$1};1')"
    fi

    if [[ $page == *"EE"* ]]; then
        page="ee $(echo $page | sed 's/ from.*//g' | awk '{$1=$1};1')"
    fi

    if [[ $page == *"Xan"* ]]; then
        page="xge $(echo $page | sed 's/ from.*//g' | awk '{$1=$1};1')"
    fi


    # Appending to json
    echo "{
    \"name\": \"$name\",
    \"desc\": [
    \"$description\"
    ]," >> ~/Programming/DND_Helper/src/main/resources/5e-SRD-Spells.json

    if [[ $higherLevel != "" ]]; then
    echo "\"higher_level\": [
    \"$higherLevel\"
    ]," >> ~/Programming/DND_Helper/src/main/resources/5e-SRD-Spells.json

    fi

    echo "\"page\": \"$page\",
    \"range\": \"$range\",
    \"components\": [
    \"$requirments\"
    ]," >> ~/Programming/DND_Helper/src/main/resources/5e-SRD-Spells.json

    if [[ $materials != "" ]]; then
    echo "\"material\": \"$materials\"," >> ~/Programming/DND_Helper/src/main/resources/5e-SRD-Spells.json
    fi

    echo "\"ritual\": \"$ritual\",
    \"duration\": \"$duration\",
    \"concentration\": \"$concentration\",
    \"casting_time\": \"$castingTime\",
    \"level\": $level,
    \"school\": {
    \"name\": \"$school\"
    },
    \"classes\": [
    {
        \"name\": \"$classes\"
    }
    ],
    \"subclasses\": []
}," >> ~/Programming/DND_Helper/src/main/resources/5e-SRD-Spells.json

done


# Cleanup
rm currentSpell
#rm links
