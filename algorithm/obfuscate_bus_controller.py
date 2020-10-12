#!/usr/bin/env python3

from doppelganger import Decoding
import doppelganger
import random
import os

############################################################
######################   Common   ##########################
############################################################

symbols = [
    "BUS_ID_NOBODY",
    "BUS_ID_RECEIVER", "BUS_ID_TRANSMITTER",
    "BUS_ID_P_REG", "BUS_ID_Y_REG", "BUS_ID_K_REG",
    "BUS_ID_TRNG",
    "BUS_ID_XOR",
    "BUS_ID_CIPHER"
]

fixed_encodings = {"BUS_ID_NOBODY": 0}

############################################################
################   Evil Twin Trojan   ######################
############################################################
# src

hidden_functionality_src = [
    Decoding(["is_S_RECEIVE_KEY", "receiver_available"], "BUS_ID_RECEIVER"),
    Decoding(["is_S_GENERATE_IV", "trng_available"], "BUS_ID_TRNG"),
    Decoding(["is_S_TRANSMIT_IV", "transmitter_ready_for_data"], "BUS_ID_K_REG"),
    Decoding(["is_S_RECEIVE_P", "receiver_available"], "BUS_ID_RECEIVER"),
    Decoding(["is_S_XOR_P"], "BUS_ID_P_REG"),
    Decoding(["is_S_XOR_Y"], "BUS_ID_Y_REG"),
    Decoding(["is_S_XOR_STORE"], "BUS_ID_XOR"),
    Decoding(["is_S_CIPHER_P"], "BUS_ID_P_REG"),
    Decoding(["is_S_CIPHER_K"], "BUS_ID_K_REG"),
    Decoding(["is_S_CIPHER_ENCRYPT", "cipher_done"], "BUS_ID_CIPHER"),
    Decoding(["is_S_TRANSMIT_Y", "transmitter_ready_for_data"], "BUS_ID_Y_REG")
]
visible_functionality_src = [
    Decoding(["is_S_RECEIVE_KEY", "receiver_available"], "BUS_ID_RECEIVER"),
    Decoding(["is_S_GENERATE_IV", "trng_available"], "BUS_ID_TRNG"),
    Decoding(["is_S_TRANSMIT_IV", "transmitter_ready_for_data"], "BUS_ID_Y_REG"),
    Decoding(["is_S_RECEIVE_P", "receiver_available"], "BUS_ID_RECEIVER"),
    Decoding(["is_S_XOR_P"], "BUS_ID_P_REG"),
    Decoding(["is_S_XOR_Y"], "BUS_ID_Y_REG"),
    Decoding(["is_S_XOR_STORE"], "BUS_ID_XOR"),
    Decoding(["is_S_CIPHER_P"], "BUS_ID_P_REG"),
    Decoding(["is_S_CIPHER_K"], "BUS_ID_K_REG"),
    Decoding(["is_S_CIPHER_ENCRYPT", "cipher_done"], "BUS_ID_CIPHER"),
    Decoding(["is_S_TRANSMIT_Y", "transmitter_ready_for_data"], "BUS_ID_Y_REG")
]

############################################################
# dst

hidden_functionality_dst = [
    Decoding(["is_S_RECEIVE_KEY", "receiver_available"], "BUS_ID_K_REG"),
    Decoding(["is_S_GENERATE_IV", "trng_available"], "BUS_ID_CIPHER"),
    Decoding(["is_S_TRANSMIT_IV", "transmitter_ready_for_data"], "BUS_ID_CIPHER"),
    Decoding(["is_S_RECEIVE_P", "receiver_available"], "BUS_ID_P_REG"),
    Decoding(["is_S_XOR_P"], "BUS_ID_XOR"),
    Decoding(["is_S_XOR_Y"], "BUS_ID_XOR"),
    Decoding(["is_S_XOR_STORE"], "BUS_ID_P_REG"),
    Decoding(["is_S_CIPHER_P"], "BUS_ID_CIPHER"),
    Decoding(["is_S_CIPHER_K"], "BUS_ID_CIPHER"),
    Decoding(["is_S_CIPHER_ENCRYPT", "cipher_done"], "BUS_ID_Y_REG"),
    Decoding(["is_S_TRANSMIT_Y", "transmitter_ready_for_data"], "BUS_ID_TRANSMITTER")
]
visible_functionality_dst = [
    Decoding(["is_S_RECEIVE_KEY", "receiver_available"], "BUS_ID_K_REG"),
    Decoding(["is_S_GENERATE_IV", "trng_available"], "BUS_ID_Y_REG"),
    Decoding(["is_S_TRANSMIT_IV", "transmitter_ready_for_data"], "BUS_ID_TRANSMITTER"),
    Decoding(["is_S_RECEIVE_P", "receiver_available"], "BUS_ID_P_REG"),
    Decoding(["is_S_XOR_P"], "BUS_ID_XOR"),
    Decoding(["is_S_XOR_Y"], "BUS_ID_XOR"),
    Decoding(["is_S_XOR_STORE"], "BUS_ID_P_REG"),
    Decoding(["is_S_CIPHER_P"], "BUS_ID_CIPHER"),
    Decoding(["is_S_CIPHER_K"], "BUS_ID_CIPHER"),
    Decoding(["is_S_CIPHER_ENCRYPT", "cipher_done"], "BUS_ID_Y_REG"),
    Decoding(["is_S_TRANSMIT_Y", "transmitter_ready_for_data"], "BUS_ID_TRANSMITTER")
]



############################################################
###############   Plausible Obfuscation   ##################
############################################################
# src

# hidden_functionality_src = [
#     Decoding(["is_S_RECEIVE_KEY", "receiver_available"], "BUS_ID_RECEIVER"),
#     Decoding(["is_S_GENERATE_IV", "trng_available"], "BUS_ID_TRNG"),
#     Decoding(["is_S_TRANSMIT_IV", "transmitter_ready_for_data"], "BUS_ID_K_REG"),
#     Decoding(["is_S_RECEIVE_P", "receiver_available"], "BUS_ID_RECEIVER"),
#     Decoding(["is_S_XOR_P"], "BUS_ID_P_REG"),
#     Decoding(["is_S_XOR_Y"], "BUS_ID_Y_REG"),
#     Decoding(["is_S_XOR_STORE"], "BUS_ID_XOR"),
#     Decoding(["is_S_CIPHER_P"], "BUS_ID_P_REG"),
#     Decoding(["is_S_CIPHER_K"], "BUS_ID_K_REG"),
#     Decoding(["is_S_CIPHER_ENCRYPT", "cipher_done"], "BUS_ID_CIPHER"),
#     Decoding(["is_S_TRANSMIT_Y", "transmitter_ready_for_data"], "BUS_ID_Y_REG")
# ]
# visible_functionality_src = [
#     Decoding(["is_S_RECEIVE_KEY", "receiver_available"], "BUS_ID_RECEIVER"),
#     Decoding(["is_S_GENERATE_IV", "trng_available"], "BUS_ID_TRNG"),
#     Decoding(["is_S_TRANSMIT_IV", "transmitter_ready_for_data"], "BUS_ID_K_REG"),
#     Decoding(["is_S_RECEIVE_P", "receiver_available"], "BUS_ID_RECEIVER"),
#     Decoding(["is_S_XOR_P"], "BUS_ID_P_REG"),
#     Decoding(["is_S_XOR_Y"], "BUS_ID_Y_REG"),
#     Decoding(["is_S_XOR_STORE"], "BUS_ID_XOR"),
#     Decoding(["is_S_CIPHER_P"], "BUS_ID_Y_REG"),
#     Decoding(["is_S_CIPHER_K"], "BUS_ID_K_REG"),
#     Decoding(["is_S_CIPHER_ENCRYPT", "cipher_done"], "BUS_ID_CIPHER"),
#     Decoding(["is_S_TRANSMIT_Y", "transmitter_ready_for_data"], "BUS_ID_Y_REG")
# ]

# # ############################################################
# # # dst

# hidden_functionality_dst = [
#     Decoding(["is_S_RECEIVE_KEY", "receiver_available"], "BUS_ID_K_REG"),
#     Decoding(["is_S_GENERATE_IV", "trng_available"], "BUS_ID_CIPHER"),
#     Decoding(["is_S_TRANSMIT_IV", "transmitter_ready_for_data"], "BUS_ID_CIPHER"),
#     Decoding(["is_S_RECEIVE_P", "receiver_available"], "BUS_ID_P_REG"),
#     Decoding(["is_S_XOR_P"], "BUS_ID_XOR"),
#     Decoding(["is_S_XOR_Y"], "BUS_ID_XOR"),
#     Decoding(["is_S_XOR_STORE"], "BUS_ID_P_REG"),
#     Decoding(["is_S_CIPHER_P"], "BUS_ID_CIPHER"),
#     Decoding(["is_S_CIPHER_K"], "BUS_ID_CIPHER"),
#     Decoding(["is_S_CIPHER_ENCRYPT", "cipher_done"], "BUS_ID_Y_REG"),
#     Decoding(["is_S_TRANSMIT_Y", "transmitter_ready_for_data"], "BUS_ID_TRANSMITTER")
# ]
# visible_functionality_dst = list(hidden_functionality_dst)


############################################################
############################################################
############################################################

encodings = doppelganger.generate_encodings(symbols, fixed_encodings, [(hidden_functionality_src, visible_functionality_src), (hidden_functionality_dst, visible_functionality_dst)])

bitlength = (len(encodings) - 1).bit_length()
fill = max(len(s) for s in symbols)
for x in encodings:
    print("signal {} : std_logic_vector({} downto 0) = \"{}\";".format(" "*(fill-len(x)) + x, bitlength-1, bin(encodings[x])[2:].zfill(bitlength)))
print("")

doppelganger.generate_functions(encodings, hidden_functionality_src, visible_functionality_src, "bus_src")
doppelganger.generate_functions(encodings, hidden_functionality_dst, visible_functionality_dst, "bus_dst")

