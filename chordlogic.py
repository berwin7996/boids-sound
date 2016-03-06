from random import random as rand
from random import choice as choice
from time import sleep

def addLists(l1, l2):
	return [a+b for (a,b) in zip(l1, l2)]

def listDivideNumber(l, n):
	return [a/float(n) for a in l]

def NumberMinusList(n, l):
	return [float(n) - a for a in l]

class ChordType:
	# Major or Minor
	Major = 0
	Minor = 1
	Aug = 2
	Dim = 3
	Sus4 = 4

	# 7th chord
	Normal = 0
	Major7 = 1
	Minor7 = 2
	Dim7 = 3

	@staticmethod
	def getNotes(type):
		notes = []
		if type[0] == ChordType.Major:
			notes += [0, 4, 7]
		elif type[0] == ChordType.Minor:
			notes += [0, 3, 7]
		elif type[0] == ChordType.Aug:
			notes += [0, 4, 8]
		elif type[0] == ChordType.Dim:
			notes += [0, 3, 6]
		elif type[0] == ChordType.Sus4:
			notes += [0, 5, 7]
		if type[1] == ChordType.Normal:
			notes.append(0)
		elif type[1] == ChordType.Major7:
			notes.append(11)
		elif type[1] == ChordType.Minor7:
			notes.append(10)
		elif type[1] == ChordType.Dim7:
			notes.append(9)
		return notes

	# Harmonic function
	Tonic = 0
	Dominant = 1
	Predominant = 2
	Subdominant = 3

class Chord:
	def init(self, root=0, type=[ChordType.Major, ChordType.Normal]):
		self.root = root
		self.type = type
		self.commonNext = []
		return self

	def getNotes(self, key):
		return ChordType.getNotes(self.type)

	def setHarmonicFunction(self, ton=1, dom=0, pred=0, subd=0):
		self.hFunc = [ton, dom, pred, subd]
		return self

	def setMood(self, mood):
		self.mood = mood
		return self

	def setBasicTension(self, t):
		self.tension = t
		return self

	def setUnstable(self, b):
		self.unstable = b
		return self

	def setCommonNext(self, commonNext):
		self.commonNext = commonNext;

	def next(self, curr_chord, curr_tension, curr_mood, curr_func):
		next_func = curr_func

		# Here we enforce the check of common following chords, bypassing all environmental factors
		commonNext = [c for c in self.commonNext if c[2] == curr_func] # filter out possible notes
		r = rand()
		for i in range(len(commonNext)):
			n, p, func_in, func_out = commonNext[i]
			r -= p
			if r < 0:
				print "Choose directly: ", n
				return n, func_out # directly choose the common chord

		if curr_chord.unstable==2 or (curr_chord.unstable==1 and rand()<0.5) or rand() < 0.5: # if chord is unstable, we always move on
			if (curr_func == ChordType.Predominant):
				if (rand() < 0.2):
					print "Move to subdominant"
					next_func = ChordType.Subdominant
				else:
					print "Move to dominant"
					next_func = ChordType.Dominant
			else:
				if (curr_func==ChordType.Dominant): 
					print "Move to tonic"
					next_func = ChordType.Tonic
				if (curr_func==ChordType.Tonic): 
					print "Move to Predominant"
					next_func = ChordType.Predominant
				if (curr_func==ChordType.Subdominant):
					print "Move to dominant"
					next_func = ChordType.Dominant
		else:
			print "Stay in current function"

		# choose next chord, and we do not want to repeat
		chords = [chord for chord in allchords if chord.hFunc[next_func]!=0 and chord != curr_chord]

		#print "Potential chords: ", [chord.__str__() for chord in chords]
		tensions = [chord.tension for chord in chords]

		moods = [chord.mood for chord in chords]

		func_values = [chord.hFunc[next_func] for chord in chords]

		tension_scores = [abs(curr_tension - t) for t in tensions]
		mood_scores = [abs(curr_mood - m) for m in moods]

		# Compute normalized scores, the larger the better
		tension_scores = NumberMinusList(1, tension_scores)
		tension_scores = listDivideNumber(tension_scores ,sum(tension_scores))
		#print "Tension score: ", ["%.2f" % v for v in tension_scores] 

		mood_scores = NumberMinusList(1, mood_scores)
		mood_scores = listDivideNumber(tension_scores, sum(mood_scores))
		#print "mood score: ", ["%.2f" % v for v in mood_scores]

		func_values = listDivideNumber(func_values, sum(func_values))

		final_scores = addLists(addLists(tension_scores, mood_scores), func_values)
		final_scores = listDivideNumber(final_scores, sum(final_scores))
		#print "Final score: ", ["%.2f" % v for v in final_scores]

		r = rand()
		next_chord = chords[0]
		for i in range(len(final_scores)):
			r -= final_scores[i]
			if r <= 0: 
				next_chord = chords[i]
				break
		return next_chord, next_func

	def __str__(self):
		dic1 = {0:"1",1:"1#", 2:"2", 3:"2#", 4:"3", 5:"4", 6:"4#", 7:"5", 8:"5#", 9:"6", 10:"6#", 11:"7"}
		s=dic1[self.root]+" "
		dic2 = {0:"Major",1:"Minor", 2:"Aug", 3:"Dim", 4:"Sus4"}
		s+=dic2[self.type[0]]+" "
		dic3 = {0:"",1:"M7", 2:"m7", 3:"D7"}
		s+=dic3[self.type[1]]
		return s


I = Chord().init(0, [ChordType.Major, ChordType.Normal]).setHarmonicFunction(1,0,0,0).setMood(1.0).setBasicTension(0.1).setUnstable(0)
ii = Chord().init(2, [ChordType.Minor, ChordType.Normal]).setHarmonicFunction(0,0,1,0).setMood(0.4).setBasicTension(0.5).setUnstable(1)
iii = Chord().init(4, [ChordType.Minor, ChordType.Normal]).setHarmonicFunction(0.5,0.5,0,0).setMood(0.4).setBasicTension(0.5).setUnstable(1)
III = Chord().init(4, [ChordType.Major, ChordType.Major7]).setHarmonicFunction(0,1,0,0).setMood(0.5).setBasicTension(0.6).setUnstable(1)
III7 = Chord().init(4, [ChordType.Major, ChordType.Normal]).setHarmonicFunction(0.2,0.8,0.0).setMood(0.5).setBasicTension(0.7).setUnstable(2)
IV = Chord().init(5, [ChordType.Major, ChordType.Normal]).setHarmonicFunction(0,0,1,0).setMood(0.6).setBasicTension(0.3).setUnstable(0)
iv_ = Chord().init(5, [ChordType.Minor, ChordType.Normal]).setHarmonicFunction(0,0,0,1).setMood(0.5).setBasicTension(0.9).setUnstable(2)
V = Chord().init(7, [ChordType.Major, ChordType.Normal]).setHarmonicFunction(0,1,0,0).setMood(0.8).setBasicTension(0.4).setUnstable(1)
V7 = Chord().init(7, [ChordType.Major, ChordType.Major7]).setHarmonicFunction(0,1,0,0).setMood(0.7).setBasicTension(0.5).setUnstable(2)
vi = Chord().init(9, [ChordType.Minor, ChordType.Normal]).setHarmonicFunction(0.8,0,0.3,0).setMood(0.1).setBasicTension(0.2).setUnstable(0)

VIsus4 = Chord().init(9, [ChordType.Sus4, ChordType.Normal]).setHarmonicFunction(0,0,0,0).setMood(0.3).setBasicTension(0.8).setUnstable(2)
VI = Chord().init(9, [ChordType.Major, ChordType.Normal]).setHarmonicFunction(1,0,0,0).setMood(0.9).setBasicTension(0.2).setUnstable(2)



III.setCommonNext([(VIsus4, 0.1, ChordType.Dominant, ChordType.Dominant),
	               (vi, 0.2, ChordType.Dominant, ChordType.Tonic)])

III7.setCommonNext([(VIsus4, 0.1, ChordType.Dominant, ChordType.Dominant),
	               (vi, 0.2, ChordType.Dominant, ChordType.Tonic)])

VIsus4.setCommonNext([(VI, 1, ChordType.Dominant ,ChordType.Tonic)])

allchords = [I,ii,iii,III,III7,IV,iv_,V,V7,vi, VIsus4, VI]

modulations = [(III, [VIsus4], I, 9, ChordType.Dominant, ChordType.Tonic),
               (I, [VI], V, 7, ChordType.Tonic, ChordType.Dominant)]



class ChordMain:
	def __init__(self):
		self.key=7
		self.current_mood=0.6
		self.current_tension=0.4
		self.current_chord=I
		self.current_func=ChordType.Tonic

		self.modulation = None
		self.modulationQueue = []

	def getNextPackedChord(self):

		# Generate randomized modulation
		mods = [m for m in modulations if m[0] == self.current_chord]
		if (rand()<self.current_tension/6 and len(mods)!=0):
			mod = choice(mods)
			print "start modulation from", self.key, "to", (self.key + mod[3])%12
			self.startModulation(mod)

		# Process modulation
		if self.modulation != None and len(self.modulationQueue) == 0:
			self.key = (self.key + self.modulation[3]) % 12
			self.current_chord = self.modulation[2]
			self.current_func = self.modulation[5]
			self.modulation = None
		elif self.modulation != None: # so there is something in queue
			self.current_chord = self.modulationQueue[0]
			del self.modulationQueue[0]
		else:
			# generate chords normally
			self.current_chord, self.current_func = self.current_chord.next(
			                        self.current_chord, 
			                        self.current_tension, 
			                        self.current_mood, 
			                        self.current_func);

		# return the decision
		print "Final decision: ", self.current_chord, "| Key: ", self.key
		return [self.key] + self.current_chord.getNotes(self.key) + [self.current_chord.unstable]

	def startModulation(self, modulation):
		self.modulation = modulation
		self.modulationQueue = [] + modulation[1]

	def setTension(self, t):
		self.current_tension = t

	def setMood(self, m):
		self.current_mood = m


# chordmachine = ChordMain()
# while True:
# 	print chordmachine.getNextPackedChord()
# 	sleep(0.5)