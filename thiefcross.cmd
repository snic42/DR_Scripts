start:

move n
move n
move n
move w
move w
move w
move w
move go bridge
move w
move w
move w
move w
move go gate
move go path
move w
move w
move nw
move w
move w
move nw
move w
move w
move sw
move w
move w
move nw
move nw
move w
move w
move nw
move w
move w
move go brook

app:
put app my bund careful
wait
pause .5
swim:
put hunt
wait
pause .5
move n
wait
pause .5
move ne
wait
pause .5
move nw
wait
pause .5
move sw
wait
pause .5
move se
wait
pause .5
move s
wait
pause .5
if $Swimming.LearningRate < 30 then goto swim
else goto return

forage:
put app my bund careful
wait
pause .5

forage2:
put collect rock
wait
pause .5
put kick rock
gosub stuncheck
if $standing = 0 then put stand
if $Foraging.LearningRate < 30 then goto forage2
else goto getgrass

stuncheck:
if $stunned = 1 then
{
	pause 10
	goto stuncheck
}
else return

return:
put app my bund careful
wait
pause .5
move e
move e
move e
move se
move e
move e
move se
move se
move e
move e
move ne
move e
move e
move se
move e
move e
move se
move e
move e
move go path
move go gate
move e
move e
move e
move e
move e
move e
move e
move e
move e
move e
move e
move n
move e
move n
move n
move e
move e
move e
move go gate

goto forage

getgrass:
put forage vine
wait
pause .5

braid:

	if $Mechanical_Lore.LearningRate > 32 then
	goto end
	else
	match getgrass You need
	match braid You begin
	match braid isn't usable for anything yet.
	match braid bundling rope
	match braid lead rope
	match new mistake
	match new error
	put braid my vine
	matchwait

new:
put put my vine in bucket
put put my vine in bucket
pause .5
goto getgrass

end:
put put my vine in bucket
put put my vine in bucket
put app my bund careful
wait
pause .5
put go gate
move w
move s
move s
move s
move s
move sw
move s
move s
move s
move w
move w
move w
move nw
move n
move n
move n
put .climbcross