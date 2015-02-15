v0.97

Changes:

- removed the apply regen unqueueing from the triggers and moved it to fst:salve ()
- added a new function to check if all the exits are rubbled
- modified ninshi_failed_salve to unqueue the applying of regen
- fixed bug with act:applying_salve when I was applying regeneration
- fixed bug with affs:prone (), wasn't adding prone when called with no arguments
- added the challenge worning off trigger for arena purposes
- fixed bug with tracking crucified from the "p" on the prompt
- fixed bug with wounds tracking, it wasn't working as it should
- added the system:arena_done () function to deal with the various resets when a spar is over
- added the gear:has () function to check for fire, frost and galvanism before setting them to auto while doing fdef
- fixed bug with not being able to have auto fire and auto frost at the same time
- added sparklies replacement; still not done, I need to eat sparklies when I'm offherb balance since eating another herb takes herb balance
- added the tracking of demon by id
- added the third and last judgement trigger
- fixed bug with applying regen while having slickness. The part where salve balance is set to 0 is done on the prompt through the queue, so I can unqueue it if I get the symp message. Should work like a charm
- fixed bug with nocure:eat_yarrow (), it wasn't deleting arteries and lacerations as it should. Modified affs:artery () and affs:lacerated () to include a reset call
- fixed bug with affs:diag_start () removing all the pseudo afflictions (like no_waterwalk) and unwield
- added the demon_ashtorath trigger
- added the luciphage demon trigger
- fixed bug with the way the timer seconds were calculated, now I use math.fmod ()
- fixed bug with the prompt queue, when I was resetting it (to delete all the items executed) I was also resetting the alerts
- modified the symbol evoke alias to use offense:exec (), so I can also sting
- added sca:cure_choke () function
- fixed minor typo in sca:check () function
- modified the name of the "alen" module to "adven"
- modified stun tracking to take into account the short stun immunity
- added contagion to the offense triggers
- modified the afflictions given by JustChorale, Methrenton now give recklessness and Shakiniel paranoia
- added support for the astrology afflictions (affs:astro (); my_nativity variable from system.lua module)
- modified the moon dark trigger to call system:poisons_on (february 2011 envoy report). Might not be right.
- fixed bug with the writhing continue triggers. They appear even if I have cured the entanglement with tipheret/summer, so now I check if I have the right afflictions before executing the scripts
- added the tracking of the soulless tarots in inventory
- fixed bug with afftarotaeon2, it wasn't adding the aeon affliction
- modified moon waning trigger to enable afftarotaeon1 and afftarotaeon2, you now see the messages
- fixed bug with diag, it was deleting the "pit" affliction
- added the syphon trigger, but ONLY as an echo. Auto syphon seems too dangerous, I will use it manually
- fixed bug with trying to apply while you had slickness. system:unqueue_cure was called twice, once from fst:<balance> and once from the trigger. Removed the second function call
- fixed bug with able:read_protection (), it was checking if the auto protection was enabled
- modified the function system:cured_queue () to receive three arguments, one the affliction name and two optional ones
- added an alert when system is off
- fixed bug with affs:poison (). When called with no argument (when loosing insomnia) it was raising an error
- fixed typo with the trigger "arena_challenged" which was messing up my entire arena tracking
- modified willhit on prompt to revert to 0 if the demon didn't attack after 8 seconds
- fixed typo with the demon_attacked script, it's "GuTTurally", not "GuTurally"
- fixed bug with act:climb () when trying to climb out of a pit, climb up out of a pit takes balance
- fixed typo with the trigger "magiclist_get" (it was "icewal" instead of "icewall")
- added bleeding for amihai, it's 280ish according to Tau; it was also increased by an envoy report
- fixed typo in stance:scan (), it was accessing the stance.to_stance variable as a table
- added rockclimbing as a way to get out of pits even if you are unable to climb
- created a new module, alen.lua, to deal with enemies/allies.
- modified the order in which cleanse affs are cured (march envoy). Now it's sap, gunk, muddy, ectoplasm, mucous, ablaze, slickness, deathmark, stench, oils.
- modified prompt:add_alert () to take a name AND a message for the alert added
- various changes and additions to aeonics/paradigmatics triggers.


v0.96 

Changes:

- added transmology/harmonics triggers and afflictions
- added display.shield ()
- fixed bug with adding/removing alerts at the prompt, I should have been ignoring capitalision
- after detecting recklessness at the prompt I am also checking to see if it was caused by a hex (added the function call affs:del_hex ())
- added the function affs:del_hex () to deal with receiving the affliction line for a hex
- fixed bug with affs:reject () not removing the right afflictions when it was called by reject_lichdom
- fixed bug with affs:reject (), sometimes it was unqueueing affs:masked () AND calling affs:masked (-1)
- fixed bug with affs:reject_try (), it wasn't checking for the "archlich" defense when enabling the "reject_lichdom" trigger
- added extra check for recklessness, ego >= maxego because as an illithoid my max ego is drained continously
- added the mucous affliction from diag ("diag184") and cure triggers "curemucous" and "curescrubmucous"
- added fly and land messages to system_offense
- fixed bug with deffing, I was putting deathsense up when I already had the deathsight defense
- fixed bug with diagnosing, the unwielded items were deleted
- fixed bug with act:waterwalk and waterbreathe, I wasn't using magic:use ("enchantment") as I should have been (the flag for the enchantment wasn't set, so there was no recharging)
- added symbchecklimbs3 for when both of my arms are dysfunctional
- minor change to the bow emote
- fixed bug with mercy, kingdom, beauty and perfection not being added to the rbal def queue
- fixed bug with affs:unwielded adding the unwielded item every time I got the unwield message for the same item
- fixed bug with offense:reset deleting my current invested powers and the pacts table
- changed all the defense triggers for highmagic, nihilism, necromancy, rituals and cosmic to be omitted from output
- removed offense:generate_drawalias and offense:set_weapon, they were absolete
- changed offense:set_current to store the id and the full name of the wielded item
- changed skills:use to use the act queue if I don't specifically tell it to use them now
- added trigger affschecklimbs2 and renamed affschecklimbs to affschecklimbs1
- changed system:check_limbs (limb, side) to use affs:condition (sidelimb)
- added support for automatic wielding: affliction "unwield", able:wield, act:wield, fst:unwield functions, a balance scan and the triggers affunwield1, affunwield2 (for when I try to use the shield/symbol and I don't have them wielded) cureunwield1 and cureunwield2
- added affs:condition ("rightleg") to check the condition of a specific limb
- added return command after scanning the todo bal queue (I loose balance, so there is no need to send another command after it)
- fixed bug with adroitness not being removed from the current available skills at daytime and added at nighttime
- improved the tracking of power discharging by memorizing the last power discharged (especially when doing darkbond)
- various modifications to my offense module and triggers
- added a new custom affliction cured by drinking allheale when I get collapsed nerves, so I can cure hemiplegy
- the cured function for burns is now called when my burnt flesh is soothed, not when I see myself healing. FURTHER TESTING REQUIRED
- fixed the parry sync triggers, they were installed as enabled
- added keeneye to combat
- triggered a new message for daytime
- various changes to how refilling/fashioning is handled, primarily with the trigger patterns
- renamed the bashing trigger nogold to bashing_nogold to avoid conflicts with refilling nogold
- added failsafe for the T_asleep alert (target asleep) to the standing trigger, if the target stands then he/she is not asleep
- fst:disable ('disrupted") wasn't called when it should have been
- stancing requires balance. Sending the stance command now raises the "bal" flag
- act:waterwalk and act:waterbreathe now use the act queue to execute
- system:set_auto now checks if various skills or enchantments are available
- system:set_auto now checks if waterwalk/waterbreathe skills or enchantments are available
- waterwalk/waterbreathe now checks for available abilities first, then uses an enchantment.
- rewritten the skills module. Now all the available abilities, with their uses and syntax, are stored in a table when I set my current skills
- fixed bug with skills:is_available not taking into account that you can use adroitness when you have acrobatics, not only when you are a lich
- modified able:powercure to take into account the increased power cost for full
- when you die, autos who take balance are disabled as to let your run if you have vitae or you reform
- fixed bug with current stance not being reset when checking defs
- fixed the name of has_deathsight trigger (it previously was has_cloak)
- fixed bug with auto waterwalk and waterbreathe, the rub command was sent at the same time
- changed the score trigger to also capture the race, so I can use auto adroitness without checking defs each time I login
- added the symptom message for trying to smoke with collapsedlungs
- added a trigger to do ql each time I follow someone
- fixed bug with the curefear2 trigger not calling fst:disable ("fear")


v0.95

Changes:
- fixed bug with scan.healing exiting prematurely if I had recklessness
- fixed bug with the potionlist display not saving the current vials (that is, none) when I have no containers in my inventory
- fixed bug with the potion list display not resetting the current vials when I have no containers in my inventory
- fixed typo with the message for not having a cube when I try to recharge
- fixed longlasting bug with auto parrying and stancing (they weren't added at the start of the bal scan, as they should have been)
- added POSSIBLE new check for trying to smoke when I get the asthma symptom message
- fixed POSSIBLE bug with affs:asthma, it was not firing fst:herb if I was trying to smoke faeleaf
- added new aliases and functions to show automatisms and settings (system:show_autos, system:show_settings)
- added the new defense start line
- added a module to track items. Right now it only tracks the current/desired number of vials. Possibly upgrade to incorporate tracking of herbs and auto vial refilling
- fixed system:cured_simple to change the focus balance to 1 (on balance) when an affliction was cured by focus body
- fixed focus body curing (I wasn't checking for leglock and throatlock)
- added/fixed sending of multiple cures that consume balance before the first one goes through, making the other fail.
- added prompt alerts for demon/angel messages, for better tracking of when they will next hit and act plan the offensive accordingly
- added a prompt alert counting down to the next time enemy demon/angle will hit
- added the eating merbloom trigger
- fixed fst:autofire to fire fst:writhing if I have the flag writhing_start.
- added support for abilities that reject afflictions --NOT DONE, to continue checking the other files after system_affs
- changed affs:add_custom to add the affliction through affs:add_queue instead of adding it directly
- fixed bug with the cured vertigo trigger
- added the option to diagnose after a certain number of masked afflictions. Any afflictions I cure will lower the number of unknown afflictions, so I don't diag unnecessarily
- added extra checks for smoking coltsfoot. If it cures insomnia, then I have no coltsfoot afflictions
- fixed longlasting bug with putting insomnia up. The pseudo-affliction was added by scan.herb, which was situated below scan.free, from where the cure was sent
- added a few ent messages, especially important for nihilists
- modified able:writhe
- added the deathmark message, the passive cure message and the diag message
- modified display.auto and display.setting
- fixed bug with tracking of skills, skills forgot were not removed
- various modifications and bug fixed to the interface module to incorporate the nihilist abilities
- fixed possible bug with using adrenaline to cure aeon, it was acting like I was trying to get the speed defense


v0.94

Changes:
!- the smoking trigger is now always enabled and it calls system:cures_on () regardless if the command was sent by the system or if it was forced. If the command was forced and if it cured something then I call pipes:smoking () from the cured function
- magic:check_default checks if the enchantment is available as a skill
- changed wounds:add so I can directly specify how much wounding I have cured, like in the case of using puer
- added rituals, cosmic, highmagic, necromancy and nihilism triggers and defenses
- changed able:contort to check if below half mana when prioritizing mana
- fixed bug with blackout curing not tracking the number of puffs left when using smoked cures
- improved curing of ungrappling, then grappling techniques.
- fixed bug with smoking coltsfoot to cure insomnia triggering the nocure for coltsfoot
- modified fst:fire to handle the display.fst message too. Subsequent changes were made to all the relevant modules/triggers/aliases
- fixed very rare bug with sending a cure while in sca, getting cured of sca before the cure went through and when the cure goes through I can't execute the command, leading to stop trying to execute that cure. The normal failsafe timers weren't activated while in sca. This has been fixed.
- added fastwrithing in sca
- fixed bug with not firing the writhing failsafes when afflicted with sca
- added target using starleaper to vanish message
- added a new alert system to the prompt. It shows the time left until an alert will expire/time since it was activated. Alerts are shown at the prompt based on the order they were created or based on user specification
- created act:compose function. Longstanding bug
- added support for sending all commands without echo
- fixed bug with writhing loop while in sca
- fixed obscure bug with trying to drink allheale to cure blackout, you are out of allheale potion and blackout gets cured after a certain time
- fixed long-lasting bug with recklessness curing
- experimenting with drinking allheale regularly while in maestoso and if I have horehound afflictions
- improved allheale curing. Now I drink allheale in parallel with other cures for serious non-custom afflictions
- improved hme curing while reckless
- fixed tracking of conscious/unconscious. Also added diag/disrupted after curing
- fixed tracking of soulless rubs
- fixed typo in affs:count
- added the necromancy leech message
- fixed the way I handle the affdemon2 message. Will focus mind now
- fixed bug with system:cured_aeon ()
- fixed type with afftarotaeon2
- added the cured trigger for crucified
- fixed bug with tracking the nihilist tail attack. The drinking of allheale wasn't unqueued when I would shrug the effects of the poison
- fixed bug with system:del_cure () in blackout.
- modified tracking of curing out of blackout. It will only be done through the prompt, not the messages.
- added the curing of blackout with allheale
- unified standing and springing up
- added system:cured_narcolepsy and system:cured_hypersomnia to fire fst:insomnia.
- fixed bug with tracking of broken arms while off arm balance
- modified curing of wounds. Now the affliction name also contains the name of the body part that needs to be cured
- fixed bug with the way the main function for handling curing was passing arguments to related cured function
- modified stancing so I would stance even if the body part is already fully parried. See how that works out.
- modified tracking of wounds for compatibility with sca curing
- fixed system-breaking bug with curing numbs
- fixed numb tracking. It wasn't good enough.
- fixed bug with the diag_start trigger, it was installing as enabled
- modified tracking of sliced open forehead as an artery to head.
- modified the tracking of lacerations/arteries to cure by number and track by body part
- went through different ways of integrating cleanse, invoke green and restore to get out of locks. Hope this time it works
- fixed applying from the alias
- fixed not deleting the flag for the affliction that I was trying to cure with regen when I saw the cure message (and what I actually cured was different from what I was trying to cure)
- fixed not deleting custom afflictions if they required the applying of regeneration
- fixed bug with tracking regen curing. It could happen that the curing message was shown right after using another cure, and before seeing what the previous cure cured. Fixed (hopefully)
- added tracking of regen curing in blackout too, just in  case I apply the regen before blackout and it cures while I am in blackout
- fixed bug with shofangi stomp line
- modified curing of sunallergy to account for the two stages or the afflictions
- fixed bug with having no writhe afflictions while in sca, it didn't register as a successfully completed action
- fixed bug with smoking coltsfoot and curing insomnia. It didn't register as loosing the insomnia defense
- fixed the applying of mending (broken or twisted) on amputated/mangled limbs. It isn't possible.
- fixed bug with affs:del_custom, it didn't actually delete the custom affliction from the current affliction, and the flag for it.
- modified affs:add_custom and affs:del_custom to use the normalized name of the cure (with the spaces replaced by "_")
- typo in used_allheale (instead of allheale I was using alheale
- fixed bug with insomnia counting toward the number of afflictions when it was used as a defense
- modified affs:count ("powercure") to account for the fact that shattered ankle is cured by a power cure
- fixed a small typo in sca:check that prevented me from detecting sca illusions
- fixed tracking blindness from the prompt
- fixed bug with tracking of truehearing if the defense was already up
- fixed bug with mis-naming the has_sixthsense message
- modified adding the pseudo-afflictions of no_rebound, no_truehearing, no_sixthsense, no_kafe to improve compatibility with sca curing
- fixed bug with smoking faeleaf tracking. It should work flawlessly now, no matter if I am curing no_rebound and not wasting herb bal, or coils and I am using herb balance
- modified the tracking of coils for compatibility with sca
- modified the tracking of vessels for compatibility with sca
- fixed the adding of no_speed and no_love to be done before the table local_affs is created, to improve compatibility with sca curing
- added pseudo-affliction no_metawake to deal with metawake and modified tracking of metawake
- added act:insomnia to deal with no_insomnia
- modified the flag for trying insomnia to be no_insomnia for consistency
- improved curing shattered ankle and chest pain against tahtetso
- moved the sca checks for a completed action from the eating/smoking messages to the actual affliction curing/offbal messages, for compatibility with blackout curing and general illusion proof
- replaced affs:aeon_check and affs:sap_check with sca:check
- created display.error to deal with system related errors, instead of display.warning
- fixed bug with affs:prone (aff) when supplying a table an the argument
- fixed bug with deleting the last_cure when calling system:cured ("blackout") when seeing messages you shouldn't have been seing if you had blackout by moving the cure deletion when calling system:cured_simple
- fixed bug with faulty last cure tracking while illusioned with sca
- fixed using powercure in sca and not curing anything. The fst:curing () failsafe wasn't disabled
- updated severeal triggers that used to use the old function for accessing nocure (nocure:found (cure)). This function doesn't delete the cure. Fixed by pointing to nocure:check (cure) instead
- fixed tracking of crotamine affliction by how advanced the poison is
- changed clot to not clot when below half mana and the priority is mana, unless bleeding a lot
- fixed several able function to not use the cure in blackout
- fixed bugs with the blackout prompt
- fixed bug with firing fst:clotting () when getting hemophilia. The failsafe will fire when I cure hemophilia instead
- fixed executing pipel in sca
- fixed bug with numbed tracking
- added condition to able:powercure ()
- fixed bug with monk razing
- fixed bug with curing out of locks
- fixed bug with applying arnica
- added levitation message when falling from trees
- new display.warning () function
- implemented tracking of outrifted herbs for better use in sca
- improved and implemented sca curing
- first version of blackout curing
- various combat messages added to system_offense.xml, system_ent.xml
- interface for studying/performing kata forms



TO DO:
- TEST SCA CURING
- add rockclimbing to sca
- Those under Bloodycaps (Shadowbeat) will heal less bleeding from CLOT. (ENVOY)

o Princessfarewell (Starhymn)'s aeon will bypass quicksilver.
o GuardianAngel added. Please see the AB. (ENVOY)
o AvengingAngel added. Please see the AB.(ENVOY)
o AngelicHost added. Please see the AB.(ENVOY)
o EverSea now causes balance/eq loss on shield failure.(ENVOY)

- demon dominate message not triggered
- grip no longer takes balance (ENVOY)
- I see picking up messages in blackout
- in choke cure what I can from the queue before I start curing the things that are stopping me from curing the most important affliction
- modify tracking of defenses by supplying for each defense a table with the name, type, syntax and able function
- what SCA condition is cured first when I have more than one from the following: sap, choke, aeon?
- in SCA, if I don't have any afflictions or if I already have heavy to the default bodyparts, use default parrying and stancing
- in SCA, selfishness and CLIMBING
- medbag
- Full (Moon) has been raised from 3p to 4p.(ENVOY)

Known Issues:
- oldscore pattern not working