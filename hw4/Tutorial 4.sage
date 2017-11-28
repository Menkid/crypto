#####
#################### Exercises 2,3, 4 and 5 ##########
#####    



##################################################
# Encoding/representations of binary values
##################################################
# In this homework, we need to manipulate binary 
# in various representations (sometimes raw ascii
# sometimes as integers etc.) 
# Here we give you methods of conversion between
# these representations. 
#
# WARNING: we give you more methods than you 
#			  need for the homework! You just need 
#			  to pick whatever is useful for you.
##################################################


#Convert a string written in hexadecimal into its numerical value
a = int("0b",16) #int("0x0b",16) would work as well
print "a =",a

#Convert a string written in binary into its numerical value
b = int("1011001",2) 
print "b =",b

#Convert an integer back into a hexadecimal string
#The 02 indicates the desired size of the string (for printing leading zeros)
#The integer a should be 0 <= a <= 255. This can be of course changed to anything
# e.g. s = "{:064X}".format(a)
#
# IF a IS A MODULAR INTEGER, DON'T FORGET TO LIFT!!!
#
s = "{:02X}".format(a)
print "a in hexa =",s

#Convert an integer back into a binary string
#The 08 indicates the desired size of the string (for printing leading zeros)
#The integer a should be 0 <= a <= 255
s = '{0:08b}'.format(b)
print "a in binary =",s

c1 = int("11",16)
c2 = int("12",16)
print "c1 =", "{:02X}".format(c1)
print "c2 =", "{:02X}".format(c2)
c3 = int("11001100", 2)
c4 = int("10100110", 2)
print "c3 =", '{0:08b}'.format(c3)
print "c4 =", '{0:08b}'.format(c4)
b1 = int("0", 2)
b2 = int("1", 2)
print "b1 =", '{0:b}'.format(b1)
print "b2 =", '{0:b}'.format(b2)


# Converting raw ascii strings (binary strings with groups of 8 bits packed into characters)
# to hexadecimal and back
import binascii
c3 = "abcdefghijklmnop"
# Encode ascii as hex string
c3_hex = binascii.b2a_hex(c3) # or c3_hex = c3.encode("hex")
print c3_hex
# Decode from hex string to string
c3 = binascii.a2b_hex(c3_hex) # or  c3 = c3_hex.decode("hex")
print c3


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


##################################################
# Bit operations in SAGE and AES
##################################################
# In this HW, you need to do some AES encryptions
# and XORs of binary strings.
# If the binary strings are represented as 
# vectors over Z_2, then xor is simply done 
# by addition.
# If the strings are represented as raw ascii
# you can use the code we give to you here.
##################################################


#XOR of strings, AES

from Crypto.Util import strxor
from Crypto.Cipher import AES

"""
performs the xor of string a and b (every character is treated as an 8-bit value)
"""
def xor(a,b):
    return strxor.strxor(a,b)

    
#AES encryption of message <m> with ECB mode under key <key>
def aes_encrypt(message, key):
    obj = AES.new(key, AES.MODE_ECB,'')
    return obj.encrypt(message)
    
#AES decryption of message <m> with ECB mode under key <key>
def aes_decrypt(message, key):
    obj = AES.new(key, AES.MODE_ECB,'')
    return obj.decrypt(message)

message = "abcdefghijklmnop"
key = "aabbaabbaabbaabb"
ciphertext = aes_encrypt(message, key)

hex_ciphertext = ciphertext.encode("hex")

print "If we try to print the ciphertext there are many unprintable characters:", ciphertext

print "So we print it in hexadecimal:", hex_ciphertext

#We get back the ciphertext 
ciphertext = hex_ciphertext.decode("hex")

plaintext = aes_decrypt(ciphertext, key)
print "the plaintext is:", plaintext


##################################################
# Binary matrices and linear systems
##################################################
# To work with binary matrices and vectors
# (matrices and vectors over GF(2))
# we can use their implementation in sage
#
# When you want to convert a vector back to 
# another representation (e.g. raw ascii)
# be careful to lift each element in the
# vector before computing with it.
##################################################

# construct a matrix over Z_2 of dimension 3x3 using
# the values in the array of arrays L
Z2 = Integers(2)
L = [[1,0,0],[0,1,0],[0,1,1]]
A = matrix(Z2, L)
print A.str()

# construct a vector over Z_2 of dim 3 and multiply
# A with X from the right
l = [1,1,1]
X = vector(Z2, l)
print str(X)
Y = A*X
print str(Y)

# we can also solve a matrix equation 
# X*A = Y
# where we know A and Y
Y = matrix(Z2, [[1,1,1],[0,1,0],[0,1,1]])
X = A.solve_left(Y)

print X.str()
print X*A == Y

#
# WARNING: when manipulating lists and vectors,
#				sage uses *the reference* of the list
#				or vector by default! 
#				try running the followig code:
l = [1,1,1]
L=[l]
l[1]=4
L.append(l)
print  str(L)

l = [1,1,1]
L=[list(l)]
l[1]=4
L.append(list(l))
print  str(L)




##################################################
# base 64
##################################################
# we provide some parameters encoded in base64.
# Although we describe the encoding using binary
# strings in the HW document, it is more 
# practical to encode from/decode to (raw) ASCII
# as given in this example.
##################################################

import base64

# To encode the string 'Red Fox!' we call:
encoded_b64 = base64.b64encode("Red Fox!")
print encoded_b64

# to decode we call
print base64.b64decode(encoded_b64)


##################################################
# connecting to server
##################################################
# In exercises 1 and 3, you need to connect to
# our server. The best way to automatize your 
# solution is to use the following code.
##################################################
"""
Connection to a server <server_name> with port <port> and send message <message> (has to end with '\n')
"""

import sys
import socket

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


##################################################
# Elliptic Curves basics
##################################################
# The following code is not strictly necessary
# for the homework (Ex 3) but it is a useful
# overview for those who need/want to do some
# computations with elliptic curves in Sage
##################################################

#Elliptic curves in Sage
#Creation of an elliptic curve with equation y^2 = x^3 + ax + b over a finite field F = GF(p)
#Command is EllipticCurve(F,[a,b])

#As an example we create the Elliptic curve with equation y^2 = x^3 + 3x + 1 over GF(29)

#First we create the finite field
F = GF(29)
#Then we create the Elliptic curve E
E = EllipticCurve(F, [3,1])
print E

#To check whether a point (x,y) is on the curve, call E.is_on_curve(x,y)
print "is the point (1,2) on the curve?",  E.is_on_curve(1,2)
print "is the point (26,20) on the curve?",  E.is_on_curve(26,20)

#To create a point P with coordinates (x,y) on E, simply call E(x,y)
P = E(26,20)
#To print a point P call P.xy()
print "The coordinates of P are", P.xy()

#To add two points P,Q call + operator
Q = E(1,11)
print "Q =", Q.xy()
print "P+Q =", (P+Q).xy()

#To multiply a point P by a constant l, call l*P
print "5Q =", (5*Q).xy()

#To obtain the point at infinity call E(0)
O = E(0)
print "Point at infinity O =", O #Not possible to call for x,y coordinates!
#To check whether a point is the point at infinity, call is_zero() function
print "Is point Q the point at infinity? ", Q.is_zero()
print "Is point O the point at infinity? ", O.is_zero()

#Compute the order of the curve. WARNING CAN BE SLOW
print "The order of E is",E.order()

#Given a x coordinate, it's possible to list all points on the curve that have this x coordinate with the function lift_x and the parameter all=True
print "The possible points (in projective form) when x = 26 are",  E.lift_x(26, all=True)
print "The possible points (in xy() form) when x = 26 are",  map(lambda u: u.xy(),E.lift_x(26, all=True))


##################################################
# Pairings over Elliptic Curves 
##################################################
# The following code is strictly necessary
# for Exercise 3. 
#
# You should copy the function
#			 "pairing(P,Q,n,E,F)" 
# to your code and use it as it is to solve Ex 3.
# The rest of the code is here to illustrate
# How to construct the field K3 and the curve E3
# in sage, and how to apply the pairing. 
#
# WARNING: the method K.multiplicative_order()
#				of field elements and the method
#				P.order() of an EC point are generally
#				SLOW!!! It works here because p is 
#				small.
##################################################

'''
Let E be a supersingular elliptic curve over the finite field F_{p^2}=Z_{p^2}[Z]/(Z^2+1).
Let P, Q and G be points on the curve E such that P, Q in <G> and |<G>| = n.
This function computes the bilinear and non-degenerate pairing e:<G> \times <G> \rightarrow F_{p^2}.

Let H be a non-cyclic subgroup of E where <G> is its proper subset.
Then, the Weil pairing w:H \times H \rightarrow F_{p^2} can be used for the pairing e.
The Weil pairing is not only bilinear and non-degenerate, but also "alternating" which means that w(P,P)=1 for all P.
So, w(P,Q)=1 as w(P,Q) = w(nG,mG) = w(G,G)^nm = 1^nm = 1

When E is supersingular, there exists H and G' in H, such that <G'> is a proper subset of H of order n and G is not in <G'>.
Then, there exists a endomorphism (or distortion map) psi: H \rightarrow H which maps <G> to <G'>.

Therefore, w(P, psi(Q)) is only bilinear and non-degenerate for <G>, as psi(Q) is not in <G>, and we use it as e(P,Q).
'''
def pairing(P,Q,n,E,F):
	'''
	This is the distortion map for the curve y^2 = x^3 + 1.
	alpha = sqrt(3)*(p-1)/2 z + (p-1)/2 is a 3rd root of 1 in Z_{p^2}[Z]/(Z^2+1).
	Then, P'=(x*alpha, y) is on the curve E if P=(x, y) on the curve.
	We can easily verify that P' is not in the subgroup generated by P by using weil pairing.
	'''
	def psi(P,E,F):
		alpha = F([1, 0]) * (F(-1)/2) + F([0, 1]) * (-sqrt(F(3))/2)
		return E(P.xy()[0]*alpha, P.xy()[1])

	Qp = psi(Q,E,F)
	return P.weil_pairing(Qp, n)

# How to create a finite field with chosen modulus
p = 23
# Create a polynomial ring over GF(p)
F.<z> = GF(p)[]
# Modulus of a finite field must be irreducible
Px = z^2+1
print "Is P(X) irreducible?", Px.is_irreducible()
# Define K = Z_p^2[Z]/(Z^2+1)
K.<x> = GF(p^2, modulus = Px)
print "The modulus of K is", K.modulus()
print "K(x^2+1) =", x^2+1
print "K(x^2) =", x^2
# Create a curve y^3 = x^3 + 1
E = EllipticCurve(K, [0,1])
# Get random point of the curve E
P = E.random_point()
n = P.order()
print "P =", P.xy()
print "ord(P) =", n
# The weil pairing w(P,P) is alternating
print "w(P,P) =", P.weil_pairing(P, n)
print "ord(w(P,P)) =", P.weil_pairing(P, n).multiplicative_order()
# The pairing e(P,P) = w(P, psi(P)) is not alternating
print "e(P,P) =", pairing(P,P,n,E,K)
print "ord(e(P,P)) =", pairing(P,P,n,E,K).multiplicative_order()
