# Better Trees [bettertrees]
Makes trees more realistic.

Leaves are climbable, but be careful, they chance break.

Leaves can fall occasionally, and they can regrow.

Please don't punch a tree, you're not strong enough to break it. You might hurt your hand though. But when you do find a tool to cut a tree down, it does fall.

Leaves can be crafted into sticks, think of it as taking the leaves off of a branch and getting a big stick.

Leaves don't like to be stacked, and you can't reattach leaves you took off of a tree.

## Dependencies
No dependencies. This loops through any and all nodes in group:tree and group:leaves and overrides them. Any mod or game providing such nodes will be affected.
- [default] (optional) - Allows for adding a craft recipe to convert leaves to sticks (1:1), as well as providing default sounds and textures.
- [3d_armor] (optional) - Experimental. Wearing armor increases chance of leaves breaking while climbing.
- [mcl_core], [mcl_sounds] (optional) - Experimental support for Mineclone games.

## Recommendations
* [loose_rocks] - scatters rocks on ground to collect to make cobble
* [charcoal] - "cook" trees to get charcoal; don't use with [coalfromtrees] as this creates a conflicting recipe, use one or the other. Not needed if using with [ethereal].
* [stripped_tree] - I can only recommend this once my PRs for it are merged. Adds bark and stripped trees.

## Credits
* @luatic - "extrusion_mesh_16.obj" - provided mesh for stick nodes
* Tenplus1 - [regrow], inspired me to make leaves and fruits regrow
* Hamlet - [soft_leaves] and its forum thread, inspired me to make this mod
* Hamlet - [hard_trees_redo] inspired me to recreate the hard trees concept
* Hamlet - [fallen_trees] inspired me to make trees fall
* VanessaE - [trunks] from [plantlife_modpack] inspired me to add sticks on the ground

## Notes
This mod replaces the need to have Hamlet's [soft_leaves], [hard_trees_redo], [fallen_trees] and the mods those were based off of. This doesn't completely replace [hard_trees_redo]. Since [hard_trees_redo] adds alternative means of getting cobble, I recommend using [loose_rocks] to make up for that functionality. It is out of the scope of this mod to do some of what [hard_trees_redo] does, such as adding the possibility of dirt nodes dropping rocks and elimination of wooden tools.

The mod [sticks_stones] also scatters rocks on the ground like [loose_rocks], but they also add a recipe to get sticks from leaves. It's a 3:1 conversion, which doesn't make sense to me; a 1:1 conversion like I have in this mod seems more realistic. Because that mod and my mod have those craft recipes, using them together will add both recipes. As such, I recommend using [loose_rocks] instead of [sticks_stones]. Plus [loose_rocks]'s rocks look really cool.

There are a handful of tree-cutting mods in ContentDB ([fallen_trees], [lumberjack], [woodcutting], [choppy], [vein_miner], [treecapitator]). This mod implements the same kind of method for tree-cutting as [fallen_trees], by just adding tree nodes to the `falling_nodes` group. I have not tested the other tree-cutting mods with this mod, so I can't guarantee that they'll work as expected. There is a [treecapitator] mod on the Forums that makes trees fall over, but it is buggy and needs a lot of TLC. I may redo it and integrate it here.

I tried to integrate the behavior from [bouncy_leaves], but it appears you can't bounce on climbable nodes nor take any damage from falling on them. So keep in mind that [bouncy_leaves] doesn't work with this mod or similar mods that make leaves climbable.

Also note that mods that enable regrowing fruits (e.g. [regrow], [regrowing]) aren't needed as this behavior is done dynamically.

In the settings, you can toggle the rendering of leaves to be bushy meshes (`true`) or regular node boxes (`false`). This is similar to what is done in [bushy_leaves]. This mod is more performant than [bushy_leaves], since I use meshes instead of node boxes (thanks to Singularis for creating meshes, see `LICENSE` file for license of those meshes)

## Potential Future Additions
These features may or may not be developed in the future, either in this mod or another.
* Make leaves potentially break when any entity is in tree (may be more resource intensive)
* Add settings to tweek chances of leaves breaking or falling, and break/fall behavior (either dig or fall)
* Make trees fall over while chopping down tree
* Add variety of schematics for tree templates
* Implement tree growth stages
* Add support for [stripped_tree] as an optional dependency to add the ability to strip trees to get bark.

## Change Log
v1.0.0 - Initial release
 
v1.0.1 - Fixed stick decoration and typo in README.md

v1.0.2 - Fixed log level

v1.1.0 - Implemented bushy leaves, regrowing fruits, removed obsolete comments

v1.2.0 - Uncommented wield_image line to fix wielding sticks; added support for MCL2 & 5