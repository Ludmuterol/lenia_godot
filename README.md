# lenia_godot
Lenia in Godot 4.1.1 using a Computeshader

Initially generates an empty playfield with the "Orbium" Preloaded
On InputEventMouseButton generates a new random playfield
the global const s is the width and height of the Playfield. It gets shared to the computeshader via Uniform buffer, so you only need to change it in the gdscript.

you can make the Kernel_rect visible to see an image of the kernel 
(but simulation still runs in the background even if invisible)

once again i followed this guide:
https://colab.research.google.com/github/OpenLenia/Lenia-Tutorial/blob/main/Tutorial_From_Conway_to_Lenia_(w_o_results).ipynb
(basically each step has its own commit)
