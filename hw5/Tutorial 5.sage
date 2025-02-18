#####
#################### Exercises 1 and 5 ##########
#####    

def connect_server(server_name, port, message):
    server = (server_name, int(port)) #calling int is required when using Sage
    s = socket.create_connection(server)
    s.send(message)
    response=''
    while True:
        data = s.recv(9000)
        if not data: break
        response = response+data
    s.close()
    return response


#####
#################### Exercises 1, 2, 3 and 5 ##########
#####    

#hashing with SHA256
import hashlib

#getting a digest in ASCII and in hexa
m='This is a message'

print 'The SHA256 digest for the message "'+m+'" in raw ASCII is', hashlib.sha256(m).digest()
print 'In hexadacimal, it is', hashlib.sha256(m).hexdigest()

####
#
# if you need to manipulate the digest in groups of four bits, 
# it may be easiest to use .hexdigest(), get the nibbles you need
# and then reconstruct raw binary ASCII
#


#####
#################### Exercises 1 and 4 ##########
#####    

def xor(a,b):
    return strxor.strxor(a,b)

def divideBlocks(string, length): 
	return [string[0+i:length+i] for i in range(0, len(string), length)]

def aes_encrypt(message, key):
    obj = AES.new(key, AES.MODE_ECB,'')
    return obj.encrypt(message)


def aes_decrypt(message, key):
    obj = AES.new(key, AES.MODE_ECB,'')
    return obj.decrypt(message)



#####
#################### Exercise 2 ##########
#####    

#convert binary strings (represented as ascii) to an integer and back
#
#		THIS CONVERSION SHOULD BE USED TO TRANSFORM
#		A BINARY STRING REPRESENTED AS ASCII TO INTEGER
#		AND BACK WITH BIG ENDIAN
#	
encf = lambda x,y: 2^8*x + y
def binascii2int(s):
	return reduce(encf, map(ord, s) )

def int2binascii(x,width):
	L=[]
	for i in xrange(width):
		# always take least significant 8 bits, convert to ASCII and then shift right
		L.append( chr(x%(2^8)) )
		x=x//(2^8)
	#revert to have correct endian
	return "".join(L[::-1])

#convert ascii strings to integers and back
#
#		THIS CONVERSION SHOULD BE USED
#		TO CONVERT MESSAGES TO INTEGERS
#
encf = lambda x,y: 2^8*x + y
def ascii2int(s):
        # the string has to be reverted so that s[0] gets multiplied by 2^(8*0)
        return reduce(encf, map(ord, s[::-1]) )

def int2ascii(x):
        L=[]
        while(x>0):
                # always take least significant 8 bits, convert to ASCII and then shift right
                L.append( chr(x%(2^8)) )
                x=x//(2^8)
        return "".join(L)





####
#### Exercise 4 #########################
####

#opening a file and reading one line at a time,
#without loading the whole file in the memory.
with open(filename,'r') as f:
	for line in f:
		line.strip()
		# code you need to do with each line


# You can interactively communicate with a server by using this class
# You can use this class as follows,
# my_connection = connection_interface(server_to_connect, port_to_connect)
# my_connection.connect()
# my_connection.send("blablabla\n")
# res = my_connection.recv()
# my_connection.disconnect()
class connection_interface:
	def __init__(self, server_name, port):
		self.target = (server_name, int(port))
		self.connected = False

	def connect(self):
		if not self.connected:
			self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
			self.s.connect(self.target)
			self.connected = True

	def disconnect(self):
		if self.connected:
			self.s.close()
			self.connected = False

	# Sends a message to the server
	# The message must be finished with '\n'
	def send(self, msg):
		if self.connected:
			self.s.send(msg)
		else:
			raise Exception("You are not connected")

	# we use '\n' as terminator of a message
	def recv(self):
		if self.connected:
			try:
				buf = self.s.recv(1024)
				while buf[-1] != '\n':
					buf += self.s.recv(1024)

				return buf
			except IndexError:
				self.connected = False
				raise Exception("You are disconnected")
		else:
			raise Exception("You are not connected")

	def reconnect(self):
		self.disconnect()
		self.connect()

####
#### Exercise 5 #########################
####

################################################## MERKLE-HASH TREE TURORIAL ################################################################

size_of_block = 32 #byte
num_leafs = 2^18

#######################
# constructing the tree
#######################

# each node of the tree is represented as a node object
# case = 0 is notr, case = 1 is given, case = 2 is computable
class node:

	def __init__(self, value, level, index, case):
		self.value = value
		self.level = level
		self.index = index
		self.case = case 


#this generates the leafs of the tree
#it reads 32 byte from the file and then add it to the list which represents the leafs 
def genleafs(f):
	leafs = []
	while len(leafs) < num_leafs:
		value = f.read(size_of_block)
		n = node(value, 0, len(leafs), 0)
		leafs.append(n)
	return leafs


#after computing the leafs with genleaf, we can use the following function to generate the merkele hash tree
#the input of hashtree function has to be leafs (generated by genleafs) and tree which is empty list []	at the beginning

def hashtree(children,tree):
	tree.append(children)
	#if the size of the children is 1 then it means that we have the root. So we need to stop after adding it
	if len(children) == 1:
		return tree
	else:	
		hash_parents = [] #the list of next level hashes 
		level = children[0].level+1 #we compute the next level
		index = 0
		j = 0
		while(j < len(children) - 1):
			value = hashlib.sha256(children[j].value + children[j+1].value).digest()
			case = 0
			n = node(value,level, index, case)
			hash_parents.append(n)
			index = index + 1
			j = j + 2
		return hashtree(hash_parents,tree)



##############################################
# computing the minimal set of nodes
##############################################

# given an index set, this algorithm finds the minumum required nodes to compute root
# case = 0 is notr (not given and not computable), case = 1 is given to user, case = 2 is computable by user
# tree includes each level of tree as a list e.g. tree[2][8] corresponds to hf_28
# at the end only the nodes having case given is given to the user
# the oracle marks the leaf which is asked by the user as 'given' and then run the below algorithm:minumumTree(0,tree)

def minumumTree(l,tree):
	G = [] #keeps the list of nodes which will be given to users
	#if we are in the level which is previous level of the root level, then we have two nodes to check
	#we check their cases and if they are 0, we mark them as a given (1)
	if l == len(tree) - 2:
		if tree[l][0].case == 0:
			tree[l][0].case == 1
			G.append(str(l)+'-'+str(0))	
		if tree[l][1].case == 0:
			tree[l][1].case == 1
			G.append(str(l)+'-'+str(1))	
		return G
	else:
		#we check each nodes as pairs in a level l.
		#if one of the pair is computable or given while its sister is notr, then we change its sister to given and we update their parents to computable
		#if the cases of both is not notr, then we mark their parent as computable
		#if both of them are notr, we don't do anything
		for i in range(0,len(tree[l]),2):
			
			if tree[l][i].case == 2 and tree[l][i+1].case == 2:
				tree[l+1][i/2].case = 2
			elif tree[l][i].case == 1 and tree[l][i+1].case == 1 and l == 0:
				tree[l+1][i/2].case = 2
				G.append(str(l)+'-'+str(i))
				G.append(str(l)+'-'+str(i+1))
			elif tree[l][i].case == 0:
				if tree[l][i+1].case != 0:
					tree[l+1][i/2].case = 2
					tree[l][i].case = 1
					if l == 0:
						G.append(str(l)+'-'+str(i+1))
					else:
						G.append(str(l)+'-'+str(i))
				else:
					tree[l+1][i/2].case = 0
			elif tree[l][i].case != 0 and tree[l][i+1].case == 0:
				tree[l+1][i/2].case = 2
				tree[l][i+1].case = 1
				if l == 0:
					G.append(str(l)+'-'+str(i))
				else:
					G.append(str(l)+'-'+str(i+1))
		#now we run the algorithm for the next level	
		return G+minumumTree(l+1,tree)





