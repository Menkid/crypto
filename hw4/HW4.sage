import sys
import socket
import base64
from Crypto.Util import strxor
from Crypto.Cipher import AES

def connect_server(server_name, port, message):
    server = (server_name, int(port)) #calling int is required when using Sage
    s = socket.create_connection(server)
    s.send(message)
    response=''
    while True: #data might come in several packets, need to wait for all of it
        data = s.recv(9000)
        if not data: break
        response = response+data
    s.close()
    return response

#AES encryption of message <m> with ECB mode under key <key>
def aes_encrypt(message, key):
    obj = AES.new(key, AES.MODE_ECB,'')
    return obj.encrypt(message)
    
#AES decryption of message <m> with ECB mode under key <key>
def aes_decrypt(message, key):
    obj = AES.new(key, AES.MODE_ECB,'')
    return obj.decrypt(message)

#converting a raw ascii string to an integer and back
# compute the integer using the horner method
# ENDIAN CONVENTION:
# the character at address 0 is multiplied with 2^0
encf = lambda x,y: 2^8*x + y
def ascii2int(s):
	# the string has to be reverted so that s[0] gets multiplied by 2^(8*0)
	return reduce(encf, map(ord, s[::-1]) )

# convert back to ascii string. the parameter "width" says
# how many ascii characters do we want in output (so that we
# append sufficiently many zero characters)
def int2ascii(x,width):
	L=[]
	for i in xrange(width):
		# always take least significant 8 bits, convert to ASCII and then shift right
		L.append( chr(x%(2^8)) )
		x=x//(2^8)
	return "".join(L)

#conversion between string and bit array, from https://stackoverflow.com/questions/10237926/convert-string-to-list-of-bits-and-viceversa
def tobits(s):
    result = []
    for c in s:
        bits = bin(ord(c))[2:]
        bits = '00000000'[len(bits):] + bits
        result.extend([int(b) for b in bits])
    return result

def frombits(bits):
    chars = []
    for b in range(len(bits) / 8):
        byte = bits[b*8:(b+1)*8]
        chars.append(chr(int(''.join([str(bit) for bit in byte]), 2)))
    return ''.join(chars)


###EX1###
c1="cfwqyglgdgvioqwpslcwumhbkrwjkreedckqfjvrqlkjwvebsufvbllqgcaihooeersucivdnznvpjwnnaacajvbqdtcqnhtsvsgkvdtozalktjmxyipwedjzjgbdhfnmv:e"

##Hardcoded because found by hand with pen&paper :) My GF was using my computer...
key = [5, 18, 2, 17, 17, 6, 8, 7, 9, 2, 4, 11, 15, 5, 8, 20, 19, 23, 12, 8, 19, 12, 6, 20, 26, 9, 3, 12, 11, 25, 17, 5, 23, 2, 16, 12, 6, 7, 7, 6, 12, 20, 26, 9, 0, 22, 4, 10, 19, 23, 18, 1, 11, 12, 21, 16, 20, 26, 13, 23, 8, 19, 0, 14, 1, 18, 17, 0, 10, 9, 2, 23, 9, 26, 25, 4, 1, 8, 22, 12, 5, 16, 19, 10, 3, 10, 2, 21, 16, 11, 20, 0, 2, 2, 3, 1, 7, 21, 23, 7, 2, 3, 4, 22, 0, 5, 10, 12, 20, 19, 23, 9, 9, 12, 9, 20, 8, 14, 0, 10, 17, 18, 7, 15, 16, 12, 6, 26, 26, 17]
i = 0
out = ""
Z = Integers(27)
for k in key:
    m = chr(int(Z(ord(c1[i]) - 97 - k)) + 97)
    i += 1
    if m == "{":
        out += " "
    else:
        out += m
print("\"" + out + "\"")


###EX2###
##M21 196 char -> 1568 bits -> 12x128 + 32 bits (13 rounds)
M21 = "Remember in elementary school you were told that in case of fire you have to line up quietly in a single file from smallest to tallest? What is the logic in that? What, do tall people burn slower?"
C21 = "FdWUxgyMCYIGlBB2zxeSM3IkXIuwCk/SJnegjNFglfCTRAyjOt/vdK7lI9ShzNBl77FuuHCEGUNr/fqV0e9j7O8kXMQltgDs6I8YEWFpCDaDPhn5Bvnty7vz5SML07fCuc8EnDJgfaOcu2BRRaeUbSnJmuOcgTj1G1RpA0cmIrWERjHKCdE38eAtw6GKP5RrbU5LOylcgqBcLNQNl4IjFoku0qO7y0KNfGeZzuwZeQCYby8wRI6zBPJCrSGHbIUN/KmEqQ=="
C22 = "Xl0PvAx2HY4Yh/Yz/yZiBK2SPLFiz3GC4dRdBVFkLEkgKYHbGoASUUpVIXXB65hC00fUnBxQppbPceg/JHtaPSRxcy/BDaoo/w+FhlUj1KaSA38+qVrJHb05MC2DvvmRf4vEpHz+8PkqWGI="
i2 = 74
C21ascii = base64.b64decode(C21)
C22 = base64.b64decode(C22)
K = strxor.strxor(M21[:16], C21ascii[:16])
#K = aes_encrypt(K, S)
M22 = ""
for i in range(6):
    Ti = aes_encrypt(int2ascii(i2 - 1, 15) + int2ascii(i, 1), K)
    M22 += strxor.strxor(Ti, C22[(16*i):((16*i)+16)])
i = 6
Tm = aes_encrypt(int2ascii(i2 - 1, 15) + int2ascii(i, 1), K)
M22 += strxor.strxor(Tm[:11], C22[16*i:])
print("\"" + M22 + "\"")

###EX3###
p3=35803119278734101091855458734908701273612327115366393387494942704125848428927
G3="024EC51BA90CCB392976220E7DBDF7A7513A21916E5D7D2BC2D5C851C9B154D3B81355E0946925FF46440F9F0BAFDF32230451E3AA02AD30194BEB2B096385D1A2"
n3=35803119278734101091855458734908701273612327115366393387494942704125848428928
A3="030E02665E03FF7D8B4F0387E4802B865DA58E0A303F8717017F8C386A1B84D58C1C1A08378B568B682C9EE67605A0AA24974B6ED14ECB6BEAE547686697498E6B"
B3="03319018F59FF219144CDC0B758CE9700B7C119C0BDD782506865E3AB3BC0C481D0E1379DDD19798271F99D487403C9BF7AF3BBAC15A3DC9943AEC2C6AF7DE64A3"
c3=4685469924199804396400885806223834196574944527141266617851075613692636840314
F.<z> = GF(p3)[]
px = z^2+1
K.<x> = GF(p3^2, modulus = px)
E = EllipticCurve(K, [0,1])


###EX5###
M51="Walder Frey eventually holds a hand up to cue the musicians to cease playing, addressing Robb and claiming that he has been negligent in his duties as a host by failing to present his king with a proper wedding gift. At this moment, Roose Bolton gives Catelyn a knowing look and glances towards his arm. Her eyes follow his gaze and she sees a bit of chain mail peaking out from his sleeve. She then lifts up his sleeve which reveals the chain mail he is wearing underneath. Roose smiles ominously and Catelyn realizes that they have been led into a trap: she slaps Roose across the face and then shouts to warn Robb, but it is too late. At Walder Frey's signal, Frey approaches Talisa Stark from behind and begins to repeatedly stab her in the abdomen with a dagger, killing her unborn child instantly and causing her to quickly succumb to her wounds. The musicians hired for the wedding reveal themselves to be a group of assassins, brandishing crossbows and firing on Robb Stark and the Northern leadership gathered in the hall.."
C51='Ipq7lUtcfcAVzkXT8B3VvNAezYz/26ZuspIJus5/gx56H67w08Twad4lyP6p8hC9b3NzJKkXKhVxNP0vigqyMTmxbrq9yZlfkI0ghXPGbuxh0nHDg4BHVTdxjI7tfEncPiZOBbhIgbvlASeegRqEDTjHrpDjOx8Hyah52GBbJcm4Y+DpdxVy/Hyc4JEYEt5zUbTQ9/01ibKAKe3RQgrMBu+oXKiz14t4z2SgrjTcURA3chejB7t+52W0wQ7STqbCKZ1Yfmw5rFfyoBi5v3T9gp+ns/uUmRbMvBjpEkF2+qv/58j2c2a2zRUNueN6sgwAIYYTIKsPirIvpSCpYo7YiG5ya62TNJcbVnokBE/huI0qW7rQz7htaYeNr0jFXbTEhUO7vgMmxHtbT3pZHSZ4RS6q5xbN5KifMmh7+0icP5PcMM8yitQjPfUxVaM4hx+HHmb7X7NDLlQGVvwkMEMpv46OkvvXmesdHV24FWmWhmr6vQfLOx756r6sPZ1RM/5PnWoNJuxKEaEyynv94ZGFJ3XOlOchvPRWb7uHLxX2XvZy51vNb81svupAenaRy6M/8qVtZMrvcwJipVtytWJTSE5Szfe1KAXtPPw3nc2jai/DVtNxro5R3ixY3kCCv42Ml9Q+stg9UBUYuHPeeg1X5qowpEJrJUZGc4bSCzJF1wwrDNqxv9Vkljes1uU6leYPsWUHIraC0iqNT+3m9h8DH2Rkgjr44Fnt+dQLUUH1iyV1Bd680gh+DpiVSGcF3fzoOkffoxQ8+S9QD8Rei8eQjA8HK/QdRjVVGTq0NW82q1sjR4cplQclY7Y4wvTp/Pey89K4B7k9VH0eP8tZIk59KJG/ksOG3wjxCTw39CgjPF4x5b2HdJ/dqDz1xF4DessCyz1AvDT7SLA7ZzFS6ATk0OQrgctvpEKlFcDLd9ILzo3OehxMTZdLWQ/vwi9IMpRTKx1up8Y2gnVYDcD0JbzG5AqVvGh1P2LoqRujpXgTOTmTigHAHdxgpgo1xbr5peN5AgrPl9A/T1KdKRs1gD6tWvN28hgXv5tt9mVb3Bedn4LzUML4hfB3wrD2YTqtQxN/xlHX/FrWSYLBAke7z+qr34HeAGGjExAxxS1nNAAKSokUOlDG3fCD5QY9Xd6/44GIO9ngrdvy9CyBTlmJB7dab+uSxS4mhoXaX0LhlbL6CEkdNBhOnJficwpcwXmjD54QUfEO83cC0twF4An56nv4eWJHIEzBGTjXcXHjEOzt89zoVnpXCgmge3vS0v+RqxbTYoRGdpgnMVr/OXPJfJAYqzmuNvUhAhlH9S2/Pumsm0GI02d/iRNCtepvg4SItGJQxiLmYn6JOFhKpRWK+JDYEuVDJ6ViAds4'
C52='FU9mVfILy1gMkipXLaraB+DWnrT985CLVGNM+WzD5n9HiI3CTw5h76ZF3FLOF4KgXjV7msz97BaNARCaX95LK7nSBqiF7dWalP+lOvXNcvsRPVaKF0vy771yMx7KbYIPf7x7BlKLk3Zu35mZXbkpy9hfQ5HwvSjz/7Ir1kTRex2KY7yZ/gNeyV3RkEIOuMJbxlIU1SN3iB0HL4zYhaJQj7NiQ9m4FaVaC7YOAVRjw2Bmu67r1nAz/MGhwSz91pfYv8gEjB3prtJ45mAI3cP1EItbVD4R9ohMXcCblpmpTy9OwC4mxqU='
C1 = base64.b64decode(C51)
k1 = strxor.strxor(M51, C1)
Z2 = Integers(2)
S = []
A = []
Y = []
for i in range(129):
    S.append(tobits(k1[i*8:(i+1)*8]))
i = 1
while i < 128:
    A.append(S[i])
    i += 2
i = 2
while i < 129:
    Y.append(S[i])
    i += 2
A = matrix(Z2, A)
Y = matrix(Z2, Y)
K51 = A.solve_right(Y)
IV = K51.solve_left(vector(Z2, S[0]))
print IV
#hardcoded the +1, sorry... rush time
nIV = [0, 1, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 0, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 0, 1, 1, 1, 1, 0, 1]
nIV = vector(Z2, nIV)
i = 0
A = []
Y = []
while i < 127:
    A.append(S[i])
    i += 2
i = 1
while i < 128:
    Y.append(S[i])
    i += 2
A = matrix(Z2, A)
Y = matrix(Z2, Y)
K52 = A.solve_right(Y)
C2 = base64.b64decode(C52)
i = 1
k2 = ""
Si = K51*nIV
k2 += frombits(Si)
while i < 29:
    Si = K52*Si
    k2 += frombits(Si)
    i += 1
    Si = K51*Si
    k2 += frombits(Si)
    i += 1
print len(k2)
print len(C2)
M = strxor.strxor(k2[:-2], C2)

print M


###EX4###
C4= "/6hKfvSeC5Cme1tQPx+gQQAYh8HBGwA8akxsN4DXwKA="
Cp = base64.b64decode(C4)
Rp = Cp[16:]
Lp = Cp[:16]
RpLp = base64.b64encode(Rp + Lp)
fooRa = base64.b64decode(connect_server("lasecpc28.epfl.ch", 6666, '217548 ' + RpLp + '\n'))
Ra = fooRa[16:]
RaLp = base64.b64encode(Ra + Lp)
RRp = base64.b64decode(connect_server("lasecpc28.epfl.ch", 6666, '217548 ' + RaLp + '\n'))
R = RRp[:16]
RpR = base64.b64encode(Rp + R)
fooL = base64.b64decode(connect_server("lasecpc28.epfl.ch", 6666, '217548 ' + RpR + '\n'))
L = fooL[16:]
print("\"" + L + R + "\"")
