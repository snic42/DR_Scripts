#debuglevel 5
put #class racial on
put #class rp on
put #class arrive off
put #class combat off
put #class joust off

# automapper.cmd version 6.3
# last changed: Aug 31, 2018

# Added handler for attempting to enter closed shops from Shroomism
# Added web retry support from Dasffion
# Added caravan support from Jailwatch
# Added swimming retry from Jailwatch
# Added search and objsearch handling from BakedMage
# Added enhanced climbing and muck support from BakedMage
# VTCifer - Added "room" type movement - used for loong command strings that need to be done in one room
# VTCifer - Added "ice" type movement  - will collect rocks when needs to slow down
# VTCifer - Added more matches for muck (black apes)
# Fixed timings
# Added "treasure map" mode from Isharon
# Replaced "tattered map" with "map" (because the adjective varies)
# VTCifer - Added additional catches for roots
# VTCifer - Added additional catch for Reaver mine -> Non-standard stand up message.  Fixed minor issue with RT and roots.
#
# 2013-07-24 - Funk -  - Merged back in previous changes + updates
# Waiting for the galley to show up - var move_BOAT ^The galley has just left|^You look around in vain for the galley
# added "^You'll need to stand up first" to move_STAND var
# added "^You almost make it to the top" to climb_FAIL
# added "^You find yourself stuck in the mud" to move_MUCK var
# added support for stowing to climb - var move_STOW ^You'll need to free up your hands first|^Not while carrying something in your hands

# 2016-12-01 - Shroom - Added updates and optimizations
# Added more catches for stunned or tripping over roots
# Added additional catches for closed shops
# Added support for knocking on a town gate (Shard) during Night to get in. (Need to add checks for Non-Citizens, may cause problems with non-citizens)
# Added catches for trying to go through gate while invisible or with a cloak concealing face.
# Added support for climbing with ropes
# Added matches for Theren tunnels so script does not get stuck in infinite loop trying to stand
# Added catch for Shard citizens now being able to enter closed shops at night
# Added stamina support for Aesry stairs - Will cast fatigue recovery buffs if possible and pause to wait for stamina

# 2017-11-13 - Shroom - Synced changes and updates from TF and Prime versions -  To make compatible across both instances
# Added ICE SKATE support for Ice Road - Checks for ice skates and wears them during ice road, also checks your footwear and puts it back on after 
# Added support for Stowing foot item when you have an item stuck at your feet
# Added missing web catch - Noobs were getting stuck on the web to Leth
# Modified handling of dropping invisibility depending on guild
# Added catches for getting thrown in Jail to properly abort automapper 
#
# 2018-7-21 - Shroom - Fixed stowfootitem routine, fixed powerwalking routine
# Cleaned up some matchres, spacing, optimized some code with help of Pelic
# 2018-7-28 - Added missing match for closed shop. Cleaned up some RegEx thanks to Ataeleos
#
# 2018-8-31 - Shroom - Added new global variable ($mount) for carpet/broom travel 
# Now if global ($mount) does not exist then it should not cause issues as this is a rare thing to have
# Old match for carpet/brooms was hanging up script for people in rooms with "carpet" in description
#
# Related macros
# ---------------
# Add the following macro for toggling powerwalking:
# #macro {P, Control} {#if {$powerwalk = 1}{#tvar powerwalk 0;#echo *** Powerwalking off}{#tvar powerwalk 1;#echo *** Powerwalking on}}
#
# Add the following macro for toggling Caravans:
# #macro {C, Control} {#if {$caravan = 1}{#tvar caravan 0;#echo *** Caravan Following off}{#tvar caravan 1;#echo *** Caravan Following on}}
#
# Related aliases
# ---------------
# Add the following aliases for toggling dragging:
# #alias {drag0} {#tvar drag 0;#unvar drag.target}
# #alias {drag1} {#tvar drag 1;#tvar drag.target $0}
# Add the following aliases for toggling treasure map mode:
# #alias {map0} {#tvar mapwalk 0}
# #alias {map1} {#tvar mapwalk 1}
#
# Type ahead declaration
# ---------------
# The following will use a global to set it by character.  This helps when you have both premium and standard accounts.
# Standard Account = 1, Premium Account = 2, LTB Premium = 3
# #var automapper.typeahead 1
# debuglevel 10
ABSOLUTE_TOP:
     if !def(automapper.typeahead) then var typeahead 0
     else var typeahead $automapper.typeahead
     if !def(caravan) then put #tvar caravan 0
     if !def(mapwalk) then put #tvar mapwalk 0
     if !def(powerwalk) then put #tvar powerwalk 0
     if !def(drag) then put #tvar drag 0
     if !def(mount) then put #tvar mount 0
     # ---------------
     action var current_path %0 when ^You go
     if ($mapwalk) then
          {
               send get my map
               waitforre ^You get|^You are already holding
          }
     var removed 0
     var checked 0
     var slow_on_ice 0
     var closed 0
     var movewait 0
     var startingStam $stamina
     var failcounter 0
     var depth 0
     var movewait 0
     var closed 0
     var checked 0
     var slow_on_ice 0
     var wearingskates 0
     var move_OK ^Obvious (paths|exits)|^It's pitch dark
     var move_FAIL ^You can't go there|^What were you referring to|^I could not find what you were referring to\.|^You can't sneak in that direction|^You can't ride your.+(broom|carpet) in that direction|^You can't ride your.+(broom|carpet) in that direction|^You can't ride that way\.$
     var move_RETRY ^\.\.\.wait|^Sorry, you may only|^Sorry, system is slow|^You can't ride your.+(broom|carpet) in that direction|^You can't ride your.+(broom|carpet) in that direction|^The weight of all|lose your balance during the effort|^You are still stunned|^You're still recovering from your recent
     var move_RETREAT ^You are engaged to|^You try to move, but you're engaged|^While in combat|^You can't do that while engaged
     var move_WEB ^You can't do that while entangled in a web|As you start to move, you find yourself snared
     var move_WAIT ^You continue climbing|^You begin climbing|^You really should concentrate on your journey|^You step onto a massive stairway
     var move_END_DELAY ^You reach|you reach\.\.\.$
     var move_STAND ^You must be standing to do that|^You can't do that while (lying down|kneeling|sitting)|you trip over an exposed root|^Stand up first\.|^You must stand first\.|^You'll need to stand up|a particularly sturdy one finally brings you to your knees\.$|You try to roll through the fall but end up on your back\.$|^Perhaps you might accomplish that if you were standing\.$
     var move_NO_SNEAK ^You can't do that here|^In which direction are you trying to sneak|^Sneaking is an inherently stealthy|^You can't sneak that way|^You can't sneak in that direction
     var move_GO ^Please rephrase that command
     var move_MUCK ^You fall into the .+ with a loud \*SPLUT\*|^You slip in .+ and fall flat on your back\!|^The .+ holds you tightly, preventing you from making much headway\.|^You make no progress in the mud|^You struggle forward, managing a few steps before ultimately falling short of your goal\.|^You find yourself stuck in the mud
     var climb_FAIL ^Trying to judge the climb, you peer over the edge\.  A wave of dizziness hits you, and you back away from .+\.|^You start down .+, but you find it hard going\.  Rather than risking a fall, you make your way back up\.|^You attempt to climb down .+, but you can't seem to find purchase\.|^You pick your way up .+, but reach a point where your footing is questionable\.  Reluctantly, you climb back down\.|^You make your way up .+\.  Partway up, you make the mistake of looking down\.  Struck by vertigo, you cling to .+ for a few moments, then slowly climb back down\.|^You approach .+, but the steepness is intimidating\.|^The ground approaches you at an alarming rate|^You start up .+, but slip after a few feet and fall to the ground\!  You are unharmed but feel foolish\.|^You almost make it to the top|^You begin to climb up .+\, but have to stop halfway as you are struck by a spell of dizziness\.|^You start to climb up .+\, but feel your grip slipping and have to stop\.|You begin to climb up the rope\, but have to stop halfway as you are struck by a spell of dizziness\|^You start to climb up .+ when your grip slips and you start to fall
     var move_CLOSED ^The door is locked up tightly for the night|^You stop as you realize that the|^(?:\w+ )+I'm sorry\, but you need to be a citizen|^BONK\! You smash your nose|^Bonk\! You smash your nose|^(?:\w+ )+I'm sorry\, I can only allow citizens in at night|^(?:\w+ )+shop is closed for the night|^A guard appears and says\, "I'm sorry\,
     var swim_FAIL ^You struggle|^You work|^You slap|^You flounder
     var move_DRAWBRIDGE ^The guard yells, "Lower the bridge|^The guard says, "You'll have to wait|^A guard yells, "Hey|^The guard yells, "Hey
     var move_ROPE.BRIDGE is already on the rope\.|You'll have to wait
     var move_STOW ^You need to empty your hands|^You'll need to free up your hands|^Not while carrying something in your hands|^You should empty your hands first\!
     var move_FATIGUE ^You're too tired to try climbing
     var move_BOAT ^The galley has just left|^You look around in vain for the galley
     var climb_mount_FAIL climb what?
     # ---------------
     gosub actions
     goto loop
     # ---------------
actions:
     action (mapper) if %movewait = 0 then shift;if %movewait = 0 then math depth subtract 1;if len("%2") > 0 then echo Next move: %2 when %move_OK
     action (mapper) goto move.failed when %move_FAIL
     action (mapper) goto move.retry when %move_RETRY|%move_WEB
     action (mapper) goto move.stand when %move_STAND
     action (mapper) var movewait 1;goto move.wait when %move_WAIT
     action (mapper) goto move.retreat when %move_RETREAT
     action (mapper) var movewait 0 when %move_END_DELAY
     action (mapper) var closed 1;goto move.closed when %move_CLOSED
     action (mapper) goto move.nosneak when %move_NO_SNEAK
     action (mapper) goto move.go when %move_GO
     action (mapper) goto move.dive when %move_DIVE
     action (mapper) goto move.muck when %move_MUCK
     action (mapper) goto move.stow when %move_STOW
     action (mapper) goto move.boat when %move_BOAT
     action (mapper) echo Will re-attempt climb in 5 seconds...;send 5 $lastcommand when ^All this climbing back and forth is getting a bit tiresome\.  You need to rest a bit before you continue\.$
     action (mapper) goto move.retry when %swim_FAIL
     action (mapper) goto move.drawbridge when %move_DRAWBRIDGE
     action (mapper) goto move.knock when The gate is closed\.  Try KNOCKing instead
     action (mapper) goto move.rope.bridge when %move_ROPE.BRIDGE
     action (mapper) goto move.fatigue when %move_FATIGUE
     action (mapper) goto move.climb.mount.fail when %climb_mount_FAIL
     action (mapper) goto move.kneel when maybe if you knelt down first\?
     action (mapper) var footitem $1;goto stowfootitem when ^You notice.*?(\w+) (?:with.*|\w+?ed.*)?at your feet, and do not wish to leave it behind\.
     action (mapper) put #var mount $1 when ^You ride your.+(broom|carpet)
     action (mapper) put #var mount 0 when ^You can't ride your.+(broom|carpet)
     action (skates) var wearingskates 1 when ^You slide your ice skates on your feet and tightly tie the laces\.|^Your ice skates help you traverse the frozen terrain\.|^Your movement is hindered a little by your ice skates\.
     action (skates) var wearingskates 0 when ^You untie your skates and slip them off of your feet\.
     action var slow_on_ice 1; echo Ice detected! when ^You had better slow down\! The ice is|^At the speed you are traveling
     action goto jailed when a sound not unlike that of a tomb|binds you in chains|firmly off to jail|drag you off to jail|brings you to the jail|the last thing you see before you black out|your possessions have been stripped|You are a wanted criminal, $charactername
     action goto jailed when your belongings have been stripped|in a jail cell wearing a set of heavy manacles|strip you of all your possessions|binds your hands behind your back|Your silence shall be taken as an indication of your guilt|The eyes of the court are upon you|Your silence can only be taken as evidence of your guilt
     return
loop:
     gosub wave
     pause 0.1
     goto loop
wave:
     if (%depth > 0) then return
     if_1 goto wave_do
     goto done
wave_do:
     var depth 0
     if_1 gosub move %1
     if %typeahead < 1 then return
     if_2 gosub move %2
     if %typeahead < 2 then return
     if_3 gosub move %3
     if %typeahead < 3 then return
     if_4 gosub move %4
     if %typeahead < 4 then return
     if_5 gosub move %5
     return
done:
     pause 0.1
     put #parse YOU HAVE ARRIVED!
     put #class arrive off
     exit
move:
     math depth add 1
     var movement $0
     var type real
     if ($drag) then
          {
               var type drag
               if matchre("%movement", "(swim|climb|web|muck|rt|wait|stairs|slow|go|script|room) ([\S ]+)") then
                    {
                         var movement drag $drag.target $2
                    }
               else
                    {
                         var movement drag $drag.target %movement
                    }
               if matchre("%movement", "^(swim|climb|web|muck|rt|wait|slow|drag|script|room|dive) ") then
                    {
                         var type $1
                         eval movement replacere("%movement", "^(swim|web|muck|rt|wait|slow|script|room|dive) ", "")
                    }
          }
     else
          {
               if ($hidden) then
                    {
                         var type sneak
                         if !matchre("%movement", "climb|go gate") then
                              {
                                   if matchre("%movement", "go ([\S ]+)") then
                                        {
                                             var movement sneak $1
                                        }
                                   else
                                        {
                                             var movement sneak %movement
                                        }
                              }
                    }
               else
                    {
                         if ("%type" = "real") then
                              {
                                   if matchre("%movement", "^(search|swim|climb|web|muck|rt|wait|slow|drag|script|room|ice|dive) ") then
                                        {
                                             var type $1
                                             eval movement replacere("%movement", "^(search|swim|web|muck|rt|wait|slow|script|room|ice|dive) ", "")
                                        }
                                   if matchre("%movement", "^(objsearch) (\S+) (.+)") then
                                        {
                                             var type objsearch
                                             var searchObj $2
                                             var movement $3
                                        }
                              }
                    }
          }
     goto move.%type
move.real:
     if (%wearingskates) then
          {
               pause 0.0001
               pause 0.0001
               send remove my skates
               wait
               send stow my skates
               wait
               var wearingskates 0
          }
     if (%removed) then
          {
               action (mapper) off
               echo *** Putting your footwear back on ****
               pause 0.0001
               pause 0.0001
               var removed 0
               send get my %item
               wait
               send wear my %item
               wait
               action (mapper) on
          }
     if (("$zoneid" = "62") && ("$game" = "DRF")) then
          {
               if "$roomid" = "41" && "%movement" = "southwest" then
                    {
                         pause 0.0001
                         pause 0.0001
                         move southwest
                         move south
                         math depth subtract 2
                         goto return
                    }
          }
     send %movement
     goto return
move.power:
     if (%depth > 1) then waiteval (1 = %depth)
     send %movement
     nextroom
     matchre MOVE.DONE ^\s*Roundtime\s*\:?
     matchre MOVE.DONE ^\s*\[Roundtime\s*\:?
     matchre MOVE.DONE ^\s*\(Roundtime\s*\:?
     matchre MOVE.DONE ^Something in the area is interfering
     send perceive
     matchwait
move.room:
     if (%depth > 1) then waiteval (1 = %depth)
     send %movement
     nextroom
     goto move.done
move.stow:
     if ("$righthand" != "Empty") then send stow right
     pause 0.2
     if ("$lefthand" != "Empty") then send stow left
     pause 0.3
     pause 0.4
     put %movement
     pause 0.1
     goto move.done
move.boat:
     matchre move.boat.arrived ^The galley (\w*) glides into the dock
     matchwait 60
     put look
     goto move.boat
move.boat.arrived:
     send %movement
     pause 0.1
     goto move.done
move.ice:
     if (%depth > 1) then waiteval (1 = %depth)
     if (!%checked) then gosub skate.check
     if (%slow_on_ice) then gosub ice.collect
     put %movement
     nextroom
     goto move.done
skate.check:
     var checked 1
     action (mapper) off
     pause 0.1
     echo *** Checking for Ice Skates! ***
     matchre skate.yes ^You tap
     matchre skate.no ^I could not|^What were you
     put tap ice skate
     matchwait 7
skate.no:
     var slow_on_ice 1
     var wearingskates 0
     action (mapper) on
     echo **** No ice skate support for you! Collect rocks like the other peasants.
     RETURN
skate.yes:
     action (mapper) on
     echo *** Success! Ice Skates Found! ***
     pause 0.1
footwear.check:
     echo *** Checking for any footwear.. ***
     pause 0.1
     matchre footware.remove (boots?|shoes?|moccasins?|sandals?|slippers?|mules|workboots?|footwraps?|footwear|spats?|chopines?|nuada|booties|clogs|buskins|cothurnes?|galoshes)
     matchre footware.remove (half-boots?|ankle-boots?|gutalles?|hessians?|brogans?|toe ring|toe bells?|toe-bells?|toe-ring|loafers?|pumps?)
     matchre footwear.none ^You aren't wearing anything like that
     matchre wearing.skates ice skates
     put inv feet
     matchwait 8
     echo **** Error! Do not recognize your footwear!
     goto skate.no
footware.remove:
     var item $0
     var removed 1
     pause 0.2
     put remove my %item
     pause 0.6
     put stow my %item
     pause 0.5
     pause 0.1
footwear.none:
     pause 0.001
     send get my skates
     wait
     send wear my skates
     wait
wearing.skates:
     pause 0.1
     var wearingskates 1
     var slow_on_ice 0
     RETURN
ice.collect.p:
     pause 0.5
ice.collect:
     pause 0.1
     action (mapper) off
     echo *** Collecting rocks and pausing so we don't slip and crack our head open
     matchre ice.collect ^\.\.\.wait|^Sorry\,
     matchre ice.return ^\s*Roundtime\s*\:?
     matchre ice.return ^\s*\[Roundtime\s*\:?
     matchre ice.return ^\s*\(Roundtime\s*\:?
     put collect rock
     matchwait
ice.return:
     var slow_on_ice 0
     pause 20
     action (mapper) on
     return
move.knock:
     matchre move.done %move_OK|All right, welcome back|opens the door just enough to let you slip through|wanted criminal
     matchre turn.cloak I can't see your face
     matchre stop.invis The gate guard can't see you
     put knock gate
     matchwait 10
     goto move.failed
stop.invis:
     if ("$guild" = "Thief") then send khri stop silence vanish
     if ("$guild" = "Necromancer") then send release eotb
     if ("$guild" = "Moon Mage") then send release rf
     pause 0.5
     pause 0.4
     goto move.knock
turn.cloak:
     put turn my cloak
     pause 0.5
     pause 0.2
     goto move.knock
move.drag:
move.sneak:
move.swim:
move.rt:
####added this to stop trainer
     if (%depth > 1) then waiteval (1 = %depth)
     eval movement replacere("%movement", "script crossingtrainerfix ", "")
     send %movement
     pause 0.1
     goto move.done
move.web:
     if ($webbed) then waiteval (!$webbed)
     pause 0.1
     send %movement
     pause 0.1
     goto move.done
move.muck:
     action (mapper) off
     pause
     if (!$standing) then send stand
     matchre move.muck ^You struggle to dig|^Maybe you can reach better that way, but you'll need to stand up for that to really do you any good\.
     matchre move.muck.done ^You manage to dig|^You will have to kneel closer|^You stand back up.|^You fruitlessly dig
     send dig
     matchwait
move.muck.done:
     action (mapper) on
     goto return.clear
move.slow:
     pause 3
     goto move.real
move.climb:
     matchre move.done %move_OK
     matchre move.climb.mount.fail climb what\?
     matchre move.climb.with.rope %climb_FAIL
     if ($mount) then eval movement replacere("%movement", "climb ", "go ")
     put %movement
     matchwait
move.climb.mount.fail:
     matchre move.done %move_OK
     if ($mount) then eval movement replacere("%movement", "climb ", "go ")
     put %movement
     matchwait
move.climb.with.rope:
     action (mapper) off
     if !matchre("$righthand|$lefthand", "braided heavy rope") then
          {
               pause 0.001
               pause 0.1
               send get my braided rope
               pause 0.2
               send uncoil my braided rope
               pause 0.5
               pause 0.4
          }
     if !matchre("$righthand|$lefthand", "heavy rope") then
          {
               pause 0.001
               pause 0.1
               send get my heavy rope
               pause 0.2
               send uncoil my heavy rope
               pause 0.5
               pause 0.4
          }
     action (mapper) on
     if (("$guild" = "Thief") && ($concentration > 50)) then
          {
               send khri flight focus
               pause 2
               pause 0.5
          }
     pause 0.001
     if matchre("$righthand|$lefthand", "heavy rope") then goto move.climb.with.app.and.rope
     matchre stow.rope %move_OK
     matchre move.climb.with.app.and.rope %climb_FAIL
     put %movement with my rope
     matchwait
move.climb.with.app.and.rope:
     eval climbobject replacere("%movement", "climb ", "")
     put appraise %climbobject quick
     waitforre ^Roundtime:|^You cannot appraise that when you are in combat
     if (("$guild" = "Thief") && ($concentration > 50)) then
          {
               pause 0.001
               send khri flight focus
               pause 2
               pause 0.5
          }
     matchre stow.rope %move_OK
     matchre move.climb.with.app.and.rope %climb_FAIL
     put %movement with my rope
     matchwait
stow.rope:
     if matchre("$righthandnoun|$lefthandnoun", "rope") then
          {
               pause 0.1
               send coil my rope
               pause 0.2
               send stow my rope
               pause 0.5
               pause 0.5
          }
     goto move.done
move.search:
     send search
     pause $roundtime
     pause 0.1
     send %movement
     pause 0.2
     goto move.done
move.objsearch:
     put search %searchObj
     wait
     pause 0.5
     if ($mount) then eval movement replacere("%movement", "climb ", "go ")
     put %movement
     pause 0.2
     goto move.done
move.script:
     if (%depth > 1) then waiteval (1 = %depth)
     action (mapper) off
     match move.script.done MOVE SUCCESSFUL
     match move.failed MOVE FAILED
     put .%movement
     matchwait
move.script.done:
     shift
     math depth subtract 1
     if (len("%2") > 0) then echo Next move: %2
     action (mapper) on
     goto move.done
move.pause:
     put %movement
     pause
     goto move.done
move.fatigue:
     echo *** YOU ARE TOO FATIGUED TO CLIMB! ***
fatigue.check:
     if ("$guild" = "Barbarian") then
          {
               send berserk avalanche
               pause 2
          }
     if ("$guild" = "Bard") then
          {
               send prep hodi 20
               pause 14
               put -cast;-2 gesture
               pause
          }
     if ("$guild" = "Empath") then
          {
               send prep refresh 20
               pause 14
               put -cast;-2 gesture
               pause
          }
     if ("$guild" = "Warrior Mage") then
          {
               send prep zephyr 20
               pause 14
               put -cast;-2 gesture
               pause
          }
     if ("$guild" = "Cleric") then
          {
               send prep EF 20
               pause 14
               put -cast;-2 gesture
               pause
          }
fatigue.wait:
     if ($stamina > 55) then
          {
               put %movement
               pause
               goto move.done
          }
     echo *** Pausing to recover stamina
     pause 10
     goto fatigue.wait
move.stairs:
move.wait:
     pause 0.2
     if (%movewait) then
          {
               matchre MOVE.DONE ^You reach|you reach|^Just when it seems
               matchwait
          }
     goto move.done
move.stand:
     action (mapper) off
     pause 0.5
     matchre move.stand %move_RETRY|^Roundtime|^You are so unbalanced|^You are still
     matchre return.clear ^You stand back up
     matchre return.clear ^You are already standing
     send stand
     matchwait
move.retreat:
     pause 0.0001
     pause 0.0001
     action (mapper) off
     if (!$standing) then send stand
     if ($hidden) then send unhide
     matchre move.retreat %move_RETRY|^Roundtime|^You retreat back
     matchre move.retreat.done ^You retreat from combat|^You sneak back out of combat
     matchre move.retreat.done ^You are already as far away as you can get
     send retreat
     matchwait
move.retreat.done:
     pause 0.0001
     pause 0.0001
     action (mapper) on
     goto return.clear
move.dive:
     if ($mount) then
          {
               eval movement replacere("%movement", "dive ", "")
               put go %movement
          }
     else put dive %movement
     goto move.done
move.go:
     send go %movement
     goto move.done
move.kneel:
     put kneel
     put %movement
     goto move.done
move.nosneak:
     if (%closed) then goto move.closed
     eval movement replacere("%movement", "sneak ", "")
     send %movement
     goto move.done
move.drawbridge:
     waitforre ^Loose chains clank as the drawbridge settles on the ground with a solid thud\.
     send %movement
     goto move.done
move.rope.bridge:
     action instant send retreat;send retreat when melee range|pole weapon range
     waitforre finally arriving|finally reaching
     action remove melee range|pole weapon range
     send %movement
     goto move.done
move.retry:
     echo
     echo *** Retry movement
     echo
     if ($webbed) then waiteval (!$webbed)
     if ($stunned) then
          {
               pause
               goto move.retry
          }
     pause
     goto return.clear
move.closed:
     echo
     echo ********************************
     echo SHOP IS CLOSED FOR THE NIGHT!
     echo ********************************
     echo
     put #parse SHOP IS CLOSED
     put #parse SHOP CLOSED
     exit
jailed:
     echo
     echo ********************************
     echo    GOT THROWN IN JAIL!
     echo    ABORTING AUTOMAPPER
     echo ********************************
     echo
     put #parse JAILED
     put #parse NAILED AND JAILED!
     put #parse THROWN IN JAIL
     exit
move.failed:
     evalmath failcounter %failcounter + 1
     if (%failcounter > 4) then
          {
               put #parse AUTOMAPPER MOVEMENT FAILED!
               put #flash
               exit
          }
     echo
     echo ********************************
     echo MOVE FAILED - Type: %type | Movement: %movement | Depth: %depth
     echo Remaining Path: %0
     var remaining_path %0
     eval remaining_path replace ("%0", " ", "|")
     echo %remaining_path(1)
     echo %remaining_path(2)
     echo RETRYING Movement...%failcounter / 5 Tries.
     echo ********************************
     pause 0.1
     put #parse MOVE FAILED!
     exit
     if (%failcounter > 3) then
          {
               echo [Trying: go %remaining_path(2) due to possible movement overload]
               send go %remaining_path(2)
          }
     put #parse MOVE FAILED
     if (%type = "search") then send %type
     pause
     echo [Moving: %movement]
     send %movement
     matchwait 5
end_retry:
     pause
     goto return.clear
caravan:
     waitforre ^Your .*\, following you\.
     gosub clear
     goto loop
POWERWALK:
     pause 0.2
     matchre POWERWALK ^\.\.\.wait|^Sorry\,
     matchre POWERWALK.DONE ^\s*Roundtime\s*\:?
     matchre POWERWALK.DONE ^\s*\[Roundtime\s*\:?
     matchre POWERWALK.DONE ^\s*\(Roundtime\s*\:?
     matchre POWERWALK.DONE ^Something in the area is interfering
     send perceive
     matchwait
POWERWALK.DONE:
     gosub clear
     goto loop
foragewalk:
     pause 0.2
     send forage $forage
     waitforre ^Roundtime|^Something in the area is interfering
     gosub clear
     goto loop
mapwalk:
     pause
     put study my map
     waitforre ^The map has a large 'X' marked in the middle of it
     gosub clear
     goto loop
return.clear:
     action (mapper) on
     var depth 0
     gosub clear
     goto loop
move.done:
     if ($caravan) then
          {
               goto caravan
          }
     if ($powerwalk) then
          {
               if (($Attunement.LearningRate = 34) || ($Attunement.Ranks = 1750)) then put #var powerwalk 0
               goto powerwalk
          }
     if ($mapwalk) then
          {
               goto mapwalk
          }
     gosub clear
     goto loop
return:
     if ($caravan) then
          {
               goto caravan
          }
     if ($powerwalk) then
          {
               if (($Attunement.LearningRate = 34) || ($Attunement.Ranks = 1750)) then put #var powerwalk 0
               goto powerwalk
          }
     if ($mapwalk) then
          {
               goto mapwalk
          }
     var movewait 0
     return
stowfootitem:
     #debug 10
     pause 0.001
     pause 0.001
     pause 0.1
     send stow %footitem
     pause 0.3
     pause 0.2
     goto ABSOLUTE_TOP