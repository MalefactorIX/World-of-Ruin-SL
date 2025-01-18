### [Table of Contents]
0. Overview
    - Glossary
    - Administration Note
    - Meter Advisory
1. LLCS Guidelines
2. LBA Guidelines
3. Smart Weapons
  
# Overview
  
### [Glossary]    
ϟϟ: "Sacred Sentries".

RAW: The amount before any other functions change it.

AP: "Armor Points". Sometimes used in place of AT (Anti-Tank) or LBA. This could represent a damage number or health.

LLCS: "Linden Lab Combat System". This is the native health system provided directly by the simulator.

RC: "Raycast". This refers to the use of the llCastRay function for target acquisition or confirmation. This is used in place of "Hitscan" which also uses raycasting as a core component.

Fortified: A term given to LBA objects which may ignore damage of 5 or less, requiring the use of dedicated AP weaponry to damage unless engaged by another vehicle or seated avatar.

### [Administration Note]
No ruleset is perfect, and this one will not be an exception. These rules serve as a guideline and a template for what is expected. As such, they may not be enforced verbatim unless offending gear proves to be degrading the combat experience for players. For guidance, please consult arena administration.

Arena administration has final say in regards to any missing or nuanced guidelines, or any allowances for specific gear.

### [Meter Advisory]
A meter is provided but -not required- to conduct LLCS combat. If you opt up for using the meter, any deaths within the combat arena will be handled by a detached system which will respawn you. Due to this, you do not need a set home in the region or join any groups. However, you will need to accept the region experience for the respawn system to work. Failure to do so will be considered a cheating offense and will prevent you from killing other combatants.

Any LLCS weapon will work natively with the meter. By default, it takes 200 RAW to kill an avatar with the tank-classes requiring 300. Due to this, the meter is classified as wearing armor and will be subject to guidelines which apply to it. The meter ignores ALL damage adjustment and will always apply the RAW damage taken.

### [Foul Play]
Foul Play is best defined as the intention to misrepresent or deceive the capabilities of the player and/or equipment being used to gain an unfair advantage. This can include giving erroneous information or reports to administration, using client-side assists which affect movement or visibility, and the use of of any gear which provide an objective advantage over similar weapons through automation.

Offenses of this nature are considered 'cheating offenses'. Due to the broad spectrum this applies to and the burden of proof required, repeated or extreme offenses will result in the individual(s) responsible being banning from doing combat in our region.

# [LLCS Guidelines]
Keep in mind, these guidelines primarily apply to infantry but may be used as a basis for vehicles as well.<br>
1. Standard munitions may only deal generic damage (Parameter 0)
    - 1a. Param 104, aka "Anti-tank", is reserved for vehicle weapons only such as tank shells or AP rockets.

2. Body Armor is only permitted to reduce damage from a single damage type. It must remain vulnerable to all other types. For overlapping types (ie. Force and Anti-Tank), you may filter for jointly.
    - 2a. Body armor may not be used with any movement assist, including dashes. This is your tradeoff for being harder to kill.
    - 2b. Body armor may not absorb more than 300 RAW LLCS damage before breaking. At least 25% of incoming damage must pierce the armor.
    - 2c. An exception to Rule 2 will be made in place of a vehicle slot. The damage threshold of Rule 2b is then increased from 300 to 1000 RAW. Limit 1 per faction.
    - 2d. Damage exceeding parameter 14, excluding 102 and 104, is not supported. Armor is forbidden from filtering for 104.

3. RC weapons may not exceed an RPM of 600 or 10 rounds per second.<br>
    - 3a. Raycast weapons must feature accuracy degradation based either on the user's movement or the distance from the target if the RPM exceeds 120, the ammo capacity exceeds 5 shots, or the reload time does not exceed 4 seconds. tl;dr - No semi-auto, 100% accurate, bunny hopping DMRs that can be spammed as fast as an assault rifle.
    - 3b. Raycast weapons exceeding 120 RPM may not deal more than 75 damage per shot, shotguns excluded as they are covered in Rule 4.

4. Raycast Shotguns may not use more than 5 rays for detection or a cone wider than 0.785 radians (PI/4) or approx. 45 degrees.
    - 4a. Shotguns have have accuracy degradation for hits beyond 0.35 radians or approx. 20 degrees, or 0.5m from the target's center.
    - 4b. Shotguns exceeding 2 rounds -and- have higher than 120 RPM may not kill in a single shot even if all pellets connect.
    - 4c. Shotguns may not have a base capacity of more than 12 rounds before reloading.
    
5. Prim shotguns may not discharge more than 4 physical projectiles per shot and those may not deal more than 75 damage each. <br>
    - 5a. Shotguns must be compliant with Rule 4c.

6. Weapons firing in excess of 1200 RPM, uses 3 or mode nodes, or with improperly gapped rez calls will be classified as an automatic shotgun.

7. All AP/AT munitions must deal LBA damage and may not use collisions to deal damage.

8. All deployable fortifications and munitions must be vulnerable to direct LBA damage.<br>
    - 8a. Objects which are "phantom" cannot be collided with and therefore are in breach of the preceding guideline.<br>
    - 8b. ADS Systems on things like tanks are permitted provided they require manual activation and have a cooldown period.

9. Defense systems which are designed to deflect or block specific projectiles outside of their physical hitbox (ie. Interceptors) are not allowed.

10. All fortifications or static deployables may only be deployed whilst the owner is on the ground.

11. Please ensure all damage-over-time effects expire after dealing 100 RAW LLCS to an avatar to avoid issues with the effects following people back towards their spawn location.

12. Infantry explosives must reload or recharge at a rate no faster than 5 seconds per munition
    - 12a. Reload rate allowances or penalties will be reviewed based damage, LBA and radius. The following rates are listed as a basis:
        - LBA: 5 per second
        - LLCS: 100
        - Radius: 5 Meters
    - 12b. No single weapon may have a capacity of more than 6 explosive munitions.

13. Equipment from defunct groups or vendors may not be permitted without prior exception.<br>
    - 13a. The following equipment blacklisted and will not be permitted under any circumstance:<br>
        - All "SAC" weapons.
        - Any "Coercion" equipment
        - Any "Alliance Navy" equipment predating 2024.
        - Any "Merczateers" equipment
        - Any "Tactical UwU/Secondary Lionheart" equipment predating 2020.

### [LBA Guidelines]

1. All LBA health systems must be open-source and compliant with the standard LBA formats.

2. If using directional armor, the weakness area must be as large as the resistant one. Only allowed for items which meet the "Fortified" classification (Rule 3).
    - 2a. Resistance may not reduce damage by more than 50%.
    - 3a. Weakness modifier must be the inverse of the resistance. If damage is reduced by 50%, weakness must be increased by at least 50%.

3. Barricades and large tanks may be Fortified.
    - 3a. Fortified barricades may not have more than 50 HP.
    - 3b. Fortified tanks may not have more than  250 HP.
    - 3c. Tank size requirement must exceed 100m Cubed (X * Y * Z) in Volume.
    
4. LBA allowance is 5 LBA per 1 second of reload for infantry. A different standard will be considered for vehicles based on their size, mobility, and number of armaments, but generally will remain around no more than 10 LBA per second of reload without prior approval.
    - 4a. Weapons which do not reload or do not have a cooldown period of at least 2 seconds may not deal LBA damage.
    
5. The total health of all objects deployed per user should not exceed 400 LBA, including vehicles. This value does not account for damage modifiers.<br>
    Objects placed in excess of this are subject to being returned.
    - 5a. While not a hard rule, these are recommended values for various objects
        - Barricades: 50
        - Light Deployables: 25
        - Light Vehicles: 50
        - Heavy Vehicles/Tanks: 250
        
6. Vehicles or weapons which can deal more than 150 LBA within the span of 2 seconds will not be allowed. Situations where other vehicles should be instantly killed should be the exception, not the norm.
    - 6a. This value does not take into account damage modifiers as they apply to the victim, only the RAW amount.

### [Smart Weapons]

1. Seeking Munitions that target infantry are only authorized to target those under the conditions of [AVATAR_FLYING](https://wiki.secondlife.com/wiki/LlGetAgentInfo)
    - 1a. While targeting infantry, projectiles may only fly up to 50m/s.
    - 2b. All projectiles must adhere to obstructions.
    
2. Seeking Munitions that target vehicles must adhere to the 5 LBA/s rule.
    - 2a. Users must require line of sight to the target for at least 2 seconds.
    - 3a. Minimum acceptable reload for any weapon is 5 seconds + 1 for every 5 LBA after 25 per reload.

3. Proximity detonated weapons (ie. Flak) are not allowed.

4. Deployables, excluding mines, which engage avatars without manual input are not allowed. (ie. Drones, Auto Turrets)
    - 4a. The exception given to mines is invalid if the trigger radius exceeds 3m or if damaging features exceed 5m in radius.
    - 4b. Trigger conditions that require physical contact with the deployable are excluded from Rules 4 and 4a.
