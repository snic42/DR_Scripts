var climbit slab
var appit coat
var song lull

start:
counter set 0
put stow left
put stow right
matchre get Remove what
matchre main You remove
put rem my armband
matchwait
get:
put get my armband
pause .5

main:
if $Arcana.LearningRate > 25 then goto climbprep
if %c = 0 then gosub collect
if %c = 2 then gosub power
if %c = 4 then gosub fiss
if %c = 6 then gosub power
if %c = 5 then gosub compen
if %c = 7 then gosub app
#if %c = 10 then put perc psych
wait
pause .5
if $mana < 15 then gosub climbsub
put prep ease 5
pause .5
put charge my armb 9
wait
pause .5
put charge my armb 9
wait
pause .5
#put charge my armb 7
#wait
#pause .5
put focus my armb
wait
pause .5
put cast
counter add 1
goto main

climbsub:
put climb prac %climbit
waitfor well-earned break.
wait 2
put stop climb
return

collect:
put collect rock
wait
pause .5
put kick pile
if $standing = 0 then put stand
return

compen:
pause .5
put get my compen
put study my compen
wait
pause .5
put turn my compen
put stow my compen
return

fiss:
pause .5
put prep fiss 10
wait 13
put harn 8
wait
pause .5
put harn 8
wait
pause .5
put cast aether
pause .5
return

app:
pause .5
put app my %appit careful
wait
pause .5
counter set 0
return

power:
pause .5
put power
wait
pause .5
return

climbprep:
put hum %song
pause .5
put wear my armb
pause .5
climbprac:
if $Climbing.LearningRate > 30 then goto collecting
put climb prac %climbit
waitfor well-earned break
goto climbprac

collecting:
put collect rock
wait
pause .5
put kick pile
if $standing = 0 then put stand
if $Foraging.LearningRate > 32 then goto swimprep
goto collecting

swimprep:
put stop hum
put climb slab
pause .5
waitfor The beach deadends at the cliff's face 
put #goto 228
waitfor [Ratha, Rocky Shore]

Forward:
put sw
wait
pause .5
put sw
wait
pause .5
put w
wait
pause .5
put nw
wait
pause .5
put w
wait
pause .5
put power
wait
pause .5

back:
put e
wait
pause .5
put se
wait
pause .5
put e
wait
pause .5
put ne
wait
pause .5
put ne
wait
pause .5
put power
wait
pause .5
if $Swimming.LearningRate < 30 then goto forward
else goto comeback

comeback:
put go gap
pause .5
put #goto 26
waitfor The beach deadends
put climb slab 
goto start
