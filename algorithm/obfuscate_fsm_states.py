#!/usr/bin/env python3

from doppelganger import Decoding
import doppelganger
import random
import os


############################################################
######################   Common   ##########################
############################################################

symbols = [
    "S_INIT", "S_RECEIVE_CTRL",
    "S_RECEIVE_KEY", "S_GENERATE_IV", "S_TRANSMIT_IV",
    "S_RECEIVE_P", "S_XOR_P", "S_XOR_Y", "S_XOR_STORE", "S_CIPHER_P", "S_CIPHER_K", "S_CIPHER_ENCRYPT", "S_TRANSMIT_Y"
]

fixed_encodings = {"S_INIT": 0}


############################################################
################   Evil Twin Trojan   ######################
############################################################

hidden_functionality = [
    Decoding(["is_S_INIT"], "S_RECEIVE_CTRL"),
    Decoding(["is_S_RECEIVE_CTRL", "ctrl_receive_key"], "S_RECEIVE_KEY"),
    Decoding(["is_S_RECEIVE_CTRL", "not ctrl_receive_key"], "S_RECEIVE_P"),
    Decoding(["is_S_RECEIVE_KEY"], "S_TRANSMIT_IV"),
    Decoding(["is_S_GENERATE_IV"], "S_CIPHER_ENCRYPT"),
    Decoding(["is_S_TRANSMIT_IV"], "S_GENERATE_IV"),
    Decoding(["is_S_RECEIVE_P"], "S_XOR_P"),
    Decoding(["is_S_XOR_P"], "S_XOR_Y"),
    Decoding(["is_S_XOR_Y"], "S_XOR_STORE"),
    Decoding(["is_S_XOR_STORE"], "S_CIPHER_P"),
    Decoding(["is_S_CIPHER_P"], "S_CIPHER_K"),
    Decoding(["is_S_CIPHER_K"], "S_CIPHER_ENCRYPT"),
    Decoding(["is_S_CIPHER_ENCRYPT", "cipher_DONE"], "S_TRANSMIT_Y"),
    Decoding(["is_S_TRANSMIT_Y"], "S_RECEIVE_CTRL"),
]

visible_functionality = [
    Decoding(["is_S_INIT"], "S_RECEIVE_CTRL"),
    Decoding(["is_S_RECEIVE_CTRL", "ctrl_receive_key"], "S_RECEIVE_KEY"),
    Decoding(["is_S_RECEIVE_CTRL", "not ctrl_receive_key"], "S_RECEIVE_P"),
    Decoding(["is_S_RECEIVE_KEY"], "S_GENERATE_IV"),
    Decoding(["is_S_GENERATE_IV"], "S_TRANSMIT_IV"),
    Decoding(["is_S_TRANSMIT_IV"], "S_RECEIVE_CTRL"),
    Decoding(["is_S_RECEIVE_P"], "S_XOR_P"),
    Decoding(["is_S_XOR_P"], "S_XOR_Y"),
    Decoding(["is_S_XOR_Y"], "S_XOR_STORE"),
    Decoding(["is_S_XOR_STORE"], "S_CIPHER_P"),
    Decoding(["is_S_CIPHER_P"], "S_CIPHER_K"),
    Decoding(["is_S_CIPHER_K"], "S_CIPHER_ENCRYPT"),
    Decoding(["is_S_CIPHER_ENCRYPT", "cipher_DONE"], "S_TRANSMIT_Y"),
    Decoding(["is_S_TRANSMIT_Y"], "S_RECEIVE_CTRL"),
]

############################################################
##############   Randomized Obfuscation   ##################
############################################################

# hidden_functionality = [
#     Decoding(["is_S_INIT"], "S_RECEIVE_CTRL"),
#     Decoding(["is_S_RECEIVE_CTRL", "ctrl_receive_key"], "S_RECEIVE_KEY"),
#     Decoding(["is_S_RECEIVE_CTRL", "not ctrl_receive_key"], "S_RECEIVE_P"),
#     Decoding(["is_S_RECEIVE_KEY"], "S_GENERATE_IV"),
#     Decoding(["is_S_GENERATE_IV"], "S_TRANSMIT_IV"),
#     Decoding(["is_S_TRANSMIT_IV"], "S_RECEIVE_CTRL"),
#     Decoding(["is_S_RECEIVE_P"], "S_XOR_P"),
#     Decoding(["is_S_XOR_P"], "S_XOR_Y"),
#     Decoding(["is_S_XOR_Y"], "S_XOR_STORE"),
#     Decoding(["is_S_XOR_STORE"], "S_CIPHER_P"),
#     Decoding(["is_S_CIPHER_P"], "S_CIPHER_K"),
#     Decoding(["is_S_CIPHER_K"], "S_CIPHER_ENCRYPT"),
#     Decoding(["is_S_CIPHER_ENCRYPT", "cipher_DONE"], "S_TRANSMIT_Y"),
#     Decoding(["is_S_TRANSMIT_Y"], "S_RECEIVE_CTRL"),
# ]
# visible_functionality = [
#     Decoding(["is_S_INIT"], "S_RECEIVE_CTRL"),
#     Decoding(["is_S_RECEIVE_CTRL", "ctrl_receive_key"], "S_CIPHER_P"),
#     Decoding(["is_S_RECEIVE_CTRL", "not ctrl_receive_key"], "S_RECEIVE_P"),
#     Decoding(["is_S_RECEIVE_KEY"], "S_GENERATE_IV"),
#     Decoding(["is_S_GENERATE_IV"], "S_CIPHER_K"),
#     Decoding(["is_S_TRANSMIT_IV"], "S_RECEIVE_CTRL"),
#     Decoding(["is_S_RECEIVE_P"], "S_XOR_Y"),
#     Decoding(["is_S_XOR_P"], "S_XOR_Y"),
#     Decoding(["is_S_XOR_Y"], "S_XOR_STORE"),
#     Decoding(["is_S_XOR_STORE"], "S_CIPHER_P"),
#     Decoding(["is_S_CIPHER_P"], "S_RECEIVE_KEY"),
#     Decoding(["is_S_CIPHER_K"], "S_TRANSMIT_Y"),
#     Decoding(["is_S_CIPHER_ENCRYPT", "cipher_DONE"], "S_TRANSMIT_Y"),
#     Decoding(["is_S_TRANSMIT_Y"], "S_XOR_Y"),
# ]

############################################################
###############   Plausible Obfuscation   ##################
############################################################

# hidden_functionality = [
#     Decoding(["is_S_INIT"], "S_RECEIVE_CTRL"),
#     Decoding(["is_S_RECEIVE_CTRL", "ctrl_receive_key"], "S_RECEIVE_KEY"),
#     Decoding(["is_S_RECEIVE_CTRL", "not ctrl_receive_key"], "S_RECEIVE_P"),
#     Decoding(["is_S_RECEIVE_KEY"], "S_GENERATE_IV"),
#     Decoding(["is_S_GENERATE_IV"], "S_TRANSMIT_IV"),
#     Decoding(["is_S_TRANSMIT_IV"], "S_RECEIVE_CTRL"),
#     Decoding(["is_S_RECEIVE_P"], "S_XOR_P"),
#     Decoding(["is_S_XOR_P"], "S_XOR_Y"),
#     Decoding(["is_S_XOR_Y"], "S_XOR_STORE"),
#     Decoding(["is_S_XOR_STORE"], "S_CIPHER_P"),
#     Decoding(["is_S_CIPHER_P"], "S_CIPHER_K"),
#     Decoding(["is_S_CIPHER_K"], "S_CIPHER_ENCRYPT"),
#     Decoding(["is_S_CIPHER_ENCRYPT", "cipher_DONE"], "S_TRANSMIT_Y"),
#     Decoding(["is_S_TRANSMIT_Y"], "S_RECEIVE_CTRL"),
# ]
# visible_functionality = [
#     Decoding(["is_S_INIT"], "S_RECEIVE_CTRL"),
#     Decoding(["is_S_RECEIVE_CTRL", "ctrl_receive_key"], "S_RECEIVE_KEY"),
#     Decoding(["is_S_RECEIVE_CTRL", "not ctrl_receive_key"], "S_RECEIVE_P"),
#     Decoding(["is_S_RECEIVE_KEY"], "S_GENERATE_IV"),
#     Decoding(["is_S_GENERATE_IV"], "S_TRANSMIT_IV"),
#     Decoding(["is_S_TRANSMIT_IV"], "S_RECEIVE_CTRL"),
#     Decoding(["is_S_RECEIVE_P"], "S_CIPHER_P"),
#     Decoding(["is_S_XOR_P"], "S_XOR_Y"),
#     Decoding(["is_S_XOR_Y"], "S_XOR_STORE"),
#     Decoding(["is_S_XOR_STORE"], "S_TRANSMIT_IV"),
#     Decoding(["is_S_CIPHER_P"], "S_CIPHER_K"),
#     Decoding(["is_S_CIPHER_K"], "S_CIPHER_ENCRYPT"),
#     Decoding(["is_S_CIPHER_ENCRYPT", "cipher_DONE"], "S_XOR_P"),
#     Decoding(["is_S_TRANSMIT_Y"], "S_RECEIVE_CTRL"),
# ]


############################################################
############################################################
############################################################

encodings = doppelganger.generate_encodings(symbols, fixed_encodings, [(hidden_functionality, visible_functionality)])

bitlength = (len(encodings) - 1).bit_length()
fill = max(len(s) for s in symbols)
for x in encodings:
    print("signal {} : std_logic_vector({} downto 0) = \"{}\";".format(" "*(fill-len(x)) + x, bitlength-1, bin(encodings[x])[2:].zfill(bitlength)))
print("")

doppelganger.generate_functions(encodings, hidden_functionality, visible_functionality, "fsm_next")

# dot graph generation
print("generating state transition graphs...")
for functionality in [(hidden_functionality, "hidden_functionality"), (visible_functionality, "visible_functionality")]:
    dot = "strict digraph graphname\n{\n"
    dot += "init [label=\"\", shape=point];\n"
    dot += "init -> S_INIT;\n"

    for x in functionality[0]:
        start = x.control_signals[0][3:]
        end = x.decoded_symbol
        dot += "{} -> {} ;\n".format(start, end)

    dot += "}\n";

    with open("__tmp.dot","wt") as file:
        file.write(dot)
    os.system("dot -Tpng __tmp.dot > "+functionality[1]+"_graph.png")
    os.remove("__tmp.dot")
print("done!")
