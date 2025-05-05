# Directory struture
1. Organised by object, not by filetype.
2. Organization should er on the side of flatness and focus on retrievability.
3. `.tscn` and `.gd` should generally not be sorted away since they need to be more retrievable than other assets like sprites.
4. `.tscn` and `.gd` files should have descriptive names, and should have the same name if relating to the same object.
5. File names should not contain redundant information that can be communicated by the name of their parent folder, except when observing rule no. 4

# Bug Magnets
## BM1: Gourt Neighbour References
Gourts keep track of their neighbours in the stack, however there no gaurentee that these references are correct and if they are not correct it could cause all manner if weird behaviour inlcuding startup crashes

# Misc.
addd gourts looking at things
twitch integtation
- chatters control NPCs
