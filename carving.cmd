action var polish.gone 1 when ^The polish is all used up, so you toss it away.
#### Variables should be, but do not have to be, set per character #####
var material stack
var saw saw
var rasp rasp
var riffler riffler
var container backpack
 
 
### Do not change these ####
var newtool none
var completed 0
var polish.gone 0
var chapter null
var page null
var item %1
var repetitions %2
 
#### If you want to make things out of other chapters, add a var of chapter#items with all the items here #####
var chapter6items short.pole|long.bone.pole
var chapter8items bludgeon
var chapter9items toe.ring|nose.ring|band|pin|anklet|bracelet|cup|tailband|hairpin|cloak.pin|earrings|medallion|amulet|pendant
var chapter10items segmented.mask|notched.aventail|notched.mask|notched.aventail|segmented.cap|segmented.gloves|ribbed.mask|ribbed.aventail|notched.cap|notched.gloves|segmented.helm|ribbed.cap|ribbed.gloves|notched.helm|segmented.balaclava|segmented.greaves|segmented.vambraces|segmented.tasset
 
if matchre("%1","%chapter6items") then var chapter 6
if matchre("%1","%chapter8items") then var chapter 8
if matchre("%1","%chapter9items") then var chapter 9
if matchre("%1","%chapter10items") then var chapter 10
 
 
start:
    put stow right
    pause .5
    put stow left
    pause .5
 
read:
    put get my carving book
    pause .5
    put turn book to chapter %chapter
    pause .5
    put read my book
    waitforre Page (\d+): (.*) %item
    var page $1
    put turn my book to page %page
    pause .5
    put study my carving book
    wait
    pause 1
    put put my carving book in my %container
    pause .5
 
prep:
    put get my %material
    pause .5
    put untie my %saw from my belt
    pause .5
 
carvestart:
    matchre riffler notice several rough, jagged
    matchre rasp determine it is no longer level|has developed an uneven texture
    matchre polish some discolored areas
    matchre done Applying the final touches|You cannot figure out how to do that
    matchre carve Roundtime
    put carve my %material with my %saw
    matchwait
 
carve:
    if "$lefthandnoun" != "%saw" then gosub replacetool saw
    matchre riffler notice several rough, jagged
    matchre rasp determine it is no longer level|has developed an uneven texture
    matchre polish some discolored areas
    matchre done Applying the final touches|You cannot figure out how to do that
    matchre carve Roundtime
    put carve my %item with my %saw
    matchwait
 
riffler:
    gosub replacetool riffler
    matchre riffler notice several rough, jagged
    matchre rasp determine it is no longer level|has developed an uneven texture
    matchre polish some discolored areas
    matchre done Applying the final touches|You cannot figure out how to do that
    matchre carve Roundtime
    put rub my %item with my %riffler
    matchwait
 
rasp:
    gosub replacetool rasp
    matchre riffler notice several rough, jagged
    matchre rasp determine it is no longer level|has developed an uneven texture
    matchre polish some discolored areas
    matchre done Applying the final touches|You cannot figure out how to do that
    matchre carve Roundtime
    put rub my %item with my %rasp
    matchwait
 
polish:
    if %polish.gone = 1 then
    {
        echo POLISH GONE
        goto carve
    }
    gosub replacetool polish
    matchre riffler notice several rough, jagged
    matchre rasp determine it is no longer level|has developed an uneven texture
    matchre polish some discolored areas
    matchre done Applying the final touches|You cannot figure out how to do that
    matchre carve Roundtime
    put apply my polish to my %item
    matchwait
 
replacetool:
        setvariable newtool $0
        if "$lefthandnoun" = "polish" then
        {
            put put my $lefthandnoun in my %container
        }
        else
        {
            put tie my $lefthandnoun to my eng belt
        }
        pause .5
        if "%newtool" = "polish" then
        {
            put get my polish from my %container
        }
            else
        {
            put untie my %newtool from my eng belt
        }
        pause .5
        return
 
 
done:
    put tie my $lefthandnoun to my eng belt
    pause .5
    put get %material
    pause .5
    put put my %material in my %container
    pause .5
    put put my %item in my %container
    pause .5
    math completed add 1
    if $Engineering.LearningRate > 30 then goto end
    if %completed < %repetitions then goto read
end:
    put #parse SCRIPT DONE
    exit