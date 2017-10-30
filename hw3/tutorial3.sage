#Chinese remainder theorem

#Solve system of equations 
# x = a1 mod ms1
# x = a2 mod ms2
# x = a3 mod ms3

#Use crt(a,ms) function where a is the list of coefficients and ms is the list of modulus

ms = [3,7,11] #List of modulus
a = [1,2,3] #List of coefficients
print "The solution of the system:"
for i in xrange(len(ms)):
    print "x =", a[i], "mod", ms[i]
print "is"
#WARNING: should be integers (use lift() if needed)
print "x = ", crt(a,ms), "mod", 3*7*11


############
#Square roots in a ring Z_n

#Exemple: Z_23
R = Integers(23)
i = R(12)
print "In the", R
print i, "is square:", i.is_square() #Tests whether it's a square in R
print i.square_root(), "is a square root of", i
print "All square roots of", i, ":", i.square_root(all=True)
print "---"

#WARNING, when n is not prime, it can be computationally expensive
#Exemple: Z_35
R = Integers(35) 
i = R(9)
print "In the", R
print i, "is square:", i.is_square() 
print i.square_root(), "is a square root of", i
print "All square roots of", i, ":", i.square_root(all=True)

############
#Quadratic residues: 
#WARNING: Listing all of them is even more expensive. 
print "All quadratic residues in Z_{29}:", quadratic_residues(29)

#Legendre and Jacobi symbol generalized by Kronecker symbol
print "Legendre (4/29):", kronecker(4,29)
print "Legendre (8/29):", kronecker(8,29)

print "Jacobi (53/29232322):", kronecker(53,29232322)
print "Jacobi (55/29232322):", kronecker(55,29232322)
print "Jacobi (54/29232322):", kronecker(54,29232322)
#Why is this last one zero? Check it!

###########
#Factoring problem
#When dealing with numbers with have small factors 
n = 2^100 - 1
f = factor(n)
print f 
print n
#WARNING: Don't try to call this method on an RSA modulus; It will take A LOT to finish!