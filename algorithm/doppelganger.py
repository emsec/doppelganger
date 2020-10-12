import random
import collections
import itertools

####################################################
####################################################
####################################################

Decoding = collections.namedtuple('Decoding', 'control_signals decoded_symbol')

####################################################
####################################################
####################################################

# computes the hamming weight
def _hw(x):
    res = 0
    while x > 0:
        res += x & 1
        x >>=1
    return res

# checks whether two encodings are 'compatible' for manipulation
# returns True if 'a' has a 1 bit wherever 'b' has a 1 bit (note that 'a' can have more 1s than 'b').
def _is_overlap(a, b):
    while b > 0:
        if b & 1 == 1 and a & 1 != 1:
            return False
        a >>=1
        b >>=1
    return True

# returns a readable string representation for the 'Decoding' named tuple
def _decoding_to_str(d):
    return " & ".join(d.control_signals) + " -> " + d.decoded_symbol

####################################################
####################################################
####################################################

def _generate_encodings_greedy(symbols, fixed_encodings, overlaps, overlapped_by):
    overlap_cnt = dict()
    q = [x for x in overlaps]
    while q:
        x = q.pop(0)
        if x not in overlap_cnt:
            overlap_cnt[x] = 0
        overlap_cnt[x] += 1

        if x in overlaps:
            q += list(overlaps[x])
        else:
            overlap_cnt[x] += 1

    encoding_order = [x[0] for x in sorted(overlap_cnt.items(), key=lambda y: -y[1])]

    bitlength = (len(symbols) - 1).bit_length()

    available_encodings = sorted(list(i for i in range(2**bitlength)), key = lambda x: _hw(x))

    encoding = dict()

    for x in fixed_encodings:
        encoding[x] = fixed_encodings[x]
        available_encodings.remove(encoding[x])

    to_do = [x for x in symbols if x not in encoding]
    q = list(encoding_order)
    while q:
        current = q.pop(0)
        if current not in to_do: continue

        to_do.remove(current)

        # assign encoding with lowest possible hw that is an overlap of all relevant states
        candidate_encodings = list()
        if current in overlaps:
            hw_bound = max(_hw(x) for x in [encoding[y] for y in overlaps[current]])
            candidate_encodings = [x for x in available_encodings if _hw(x) > hw_bound]
            candidate_encodings = [x for x in candidate_encodings if all(_is_overlap(x, encoding[y]) for y in overlaps[current])]
        else:
            candidate_encodings = [available_encodings[0]]

        if len(candidate_encodings) == 0:
            print("ERROR! cannot generate all required overlaps")
            return None

        encoding[current] = candidate_encodings[0]
        available_encodings.remove(encoding[current])

        if current in overlapped_by:
            q += overlapped_by[current]

    # fill remaining encodings
    available_encodings.sort()
    for x in to_do:
        # encoding[x] = random.choice(available_encodings)
        encoding[x] = available_encodings[0]
        available_encodings.remove(encoding[x])

    return encoding

def _generate_encodings_exhaustive(symbols, fixed_encodings, overlaps, overlapped_by):
    bitlength = (len(symbols) - 1).bit_length()

    available_encodings = [i for i in range(2**bitlength)]
    for s in fixed_encodings:
        available_encodings.remove(fixed_encodings[s])

    overlap_cnt = dict()
    q = [x for x in overlaps]
    while q:
        x = q.pop(0)
        if x not in overlap_cnt:
            overlap_cnt[x] = 0
        overlap_cnt[x] += 1

        if x in overlaps:
            q += list(overlaps[x])
        else:
            overlap_cnt[x] += 1

    encoding_order = [x[0] for x in sorted(overlap_cnt.items(), key=lambda y: -y[1]) if x not in fixed_encodings]

    q = [(encoding_order, available_encodings, dict(fixed_encodings))]
    while q:
        encoding_order, available_encodings, chosen_encodings = q.pop(0)

        if not encoding_order:
            break

        s = encoding_order[0]

        for e in available_encodings:
            chosen_encodings[encoding_order[0]] = e

            if s in overlaps and not all(_is_overlap(chosen_encodings[s], chosen_encodings[y]) for y in overlaps[s]):
                    continue

            q.append((encoding_order[1:], [x for x in available_encodings if x != e], dict(chosen_encodings)))

    available_encodings = [i for i in range(2**bitlength)]
    for s in chosen_encodings:
        available_encodings.remove(chosen_encodings[s])

    for s in symbols:
        if s not in chosen_encodings:
            chosen_encodings[s] = available_encodings.pop(0)

    return chosen_encodings


def generate_encodings(symbols, fixed_encodings, functionalities):
    symbols = sorted(list(set(symbols)))

    # important for encoding generation
    different_target = list()

    for hidden_functionality, visible_functionality in functionalities:
        hidden_functionality = [Decoding(tuple(x.control_signals), x.decoded_symbol) for x in hidden_functionality]
        visible_functionality = [Decoding(tuple(x.control_signals), x.decoded_symbol) for x in visible_functionality]

        for h in hidden_functionality:
            candidates = list()
            for v in visible_functionality:
                if set(h.control_signals).issubset(set(v.control_signals)) and v.decoded_symbol != h.decoded_symbol:
                    candidates.append(v)
            if candidates:
                v = sorted(candidates, key=lambda x : -len(x.control_signals))[0]
                different_target.append((h,v))
                visible_functionality.remove(v)

    # Encoding selection
    overlaps = dict()
    overlapped_by = dict()
    for h, v in different_target:
        if h.decoded_symbol not in overlapped_by:
            overlapped_by[h.decoded_symbol] = set()
        overlapped_by[h.decoded_symbol].add(v.decoded_symbol)
        if v.decoded_symbol not in overlaps:
            overlaps[v.decoded_symbol] = set()
        overlaps[v.decoded_symbol].add(h.decoded_symbol)

    for x in symbols:
        if x in overlapped_by:
            overlapped_by[x] = list(overlapped_by[x])
        else:
            overlapped_by[x] = list()

    # detect circular dependency
    for start in symbols:
        if start not in overlaps: continue
        q = [(x, [start]) for x in (overlaps[start])]
        seen = set()
        while q:
            x, path = q.pop(0)
            if x == start:
                print("ERROR! circular dependency for overlaps:", " -> ".join(path + [x]))
                return None
            if x in seen: continue
            seen.add(x)
            if x in overlaps:
                q += [(y, path + [x]) for y in overlaps[x]]


    print("trying greedy algorithm...")
    encodings = _generate_encodings_greedy(symbols, fixed_encodings, overlaps, overlapped_by)
    if encodings:
        print("greedy algorithm successful")
        return encodings

    print("trying exhaustive algorithm...")
    encodings = _generate_encodings_exhaustive(symbols, fixed_encodings, overlaps, overlapped_by)
    if encodings:
        print("exhaustive algorithm successful")
        return encodings

    print("ERROR! no encoding scheme can implement the requested functionalities")
    return None



def generate_functions(encodings, hidden_functionality, visible_functionality, next_output_signal_name, print_info = False):
    if encodings == None:
        return False

    hidden_functionality = [Decoding(tuple(x.control_signals), x.decoded_symbol) for x in hidden_functionality]
    visible_functionality = [Decoding(tuple(x.control_signals), x.decoded_symbol) for x in visible_functionality]
    bitlength = (len(encodings) - 1).bit_length()

    # important for function generation
    unchanged = list()
    different_target = list()

    different_transition = list()
    added = list()

    processed = set()

    for h in hidden_functionality:
        if h in visible_functionality:
            unchanged.append(h)
            processed.add(h)
            visible_functionality.remove(h)
    hidden_functionality = [x for x in hidden_functionality if x not in processed]

    for h in hidden_functionality:
        candidates = list()
        for v in visible_functionality:
            if set(h.control_signals).issubset(set(v.control_signals)) and v.decoded_symbol == h.decoded_symbol:
                candidates.append(v)
        if candidates:
            v = sorted(candidates, key=lambda x : -len(x.control_signals))[0]
            different_transition.append((h,v))
            processed.add(h)
            visible_functionality.remove(v)
    hidden_functionality = [x for x in hidden_functionality if x not in processed]


    for h in hidden_functionality:
        candidates = list()
        for v in visible_functionality:
            if set(h.control_signals).issubset(set(v.control_signals)) and v.decoded_symbol != h.decoded_symbol:
                candidates.append(v)
        if candidates:
            v = sorted(candidates, key=lambda x : -len(x.control_signals))[0]
            different_target.append((h,v))
            if set(h.control_signals) != set(v.control_signals):
                different_transition.append((h,v))
            processed.add(h)
            visible_functionality.remove(v)
    hidden_functionality = [x for x in hidden_functionality if x not in processed]


    for t in visible_functionality:
        added.append(t)
    hidden_functionality = [x for x in hidden_functionality if x not in processed]

    if print_info:
        print("Analysis of input:")
        print("")

        if unchanged:
            print("unchanged decodings:")
            for x in unchanged:
                print("  "+_decoding_to_str(x))
            print("")

        if different_target:
            print("decodings with different output symbols:")
            width = max(max(len(_decoding_to_str(x)) for x,y in different_target), len("hidden functionality"))
            print(("  {:<"+str(width)+"}    {}").format("hidden functionality", "visible functionality"))
            for x,y in different_target:
                print(("  {:<"+str(width)+"}    {}").format(_decoding_to_str(x), _decoding_to_str(y)))
            print("")

        if different_transition:
            print("decodings with different control signals:")
            width = max(max(len(_decoding_to_str(x)) for x,y in different_target), len("hidden functionality"))
            print(("  {:<"+str(width)+"}    {}").format("hidden functionality", "visible functionality"))
            for x,y in different_transition:
                print(("  {:<"+str(width)+"}    {}").format(_decoding_to_str(x), _decoding_to_str(y)))
            print("")

        if added:
            print("decodings only available in visible functionality:")
            for x in added:
                print("  "+ _decoding_to_str(x))
            print("")

        if hidden_functionality:
            print("ERROR: the hidden functionality is not a subset of the visible functionality!")
            for x in hidden_functionality:
                print("  "+ _decoding_to_str(x))
            return False

        print("")

    ####################################################
    ####################################################
    ####################################################

    # generating functions for hidden functionality

    functions = dict()
    for i in range(bitlength):
        functions[i] = list()

        for t in unchanged:
            if (encodings[t.decoded_symbol] >> i) & 1 == 1:
                conditions = list()
                for s in t.control_signals:
                    conditions.append((s, True))
                functions[i].append(conditions)

        for h, v in set(different_target) | set(different_transition):
            flag = (encodings[h.decoded_symbol] >> i) & 1 == 1
            if flag or (encodings[v.decoded_symbol] >> i) & 1 == 1:
                conditions = list()
                for s in v.control_signals:
                    conditions.append((s, flag and s in h.control_signals))
                functions[i].append(sorted(conditions, key = lambda x : -x[1]))

        for t in added:
            if (encodings[t.decoded_symbol] >> i) & 1 == 1:
                conditions = list()
                for s in t.control_signals:
                    conditions.append((s, False))
                functions[i].append(conditions)

    def _score(terms):
        if all(x[1] for x in terms):
            return 0
        if any(x[1] for x in terms):
            return 1
        return 2

    for i in range(bitlength):
        functions[i].sort(key = lambda x: _score(x))

    hint = "// ignore line to enable hidden functionality"
    for i in range(bitlength):
        print("{}({}) <= ".format(next_output_signal_name, i))
        print("    ", end="")
        for j, terms in enumerate(functions[i]):
            in_ignore = False
            if j != 0:
                print("    or ", end="")

            if all(x[1] for x in terms):
                print("({})".format(" and ".join(x[0] for x in terms)))
            elif not any(x[1] for x in terms):
                print("({})  {}".format(" and ".join(x[0] for x in terms), hint))
            else:
                idx_first_false = [x[1] for x in terms].index(False)
                pre = " and ".join(x[0] for x in terms[:idx_first_false])
                post = " and ".join(x[0] for x in terms[idx_first_false:])
                print("(")
                if pre:
                    print("     "+pre)

                print("       ", end="")
                if pre:
                    print(" and ", end="")
                print(post+ "  " + hint)
                print("    )")

        print("    ;")
        print("")

    return True

