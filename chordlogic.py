from random import random as rand
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
		return self

	def getNotes(self, key):
		return [(key+self.root+i)%12 for i in ChordType.getNotes(self.type)]

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

	def next(self, curr_chord, curr_tension, curr_mood, curr_func):
		next_func = curr_func
		if curr_chord.unstable or rand() < 0.5: # if chord is unstable, we always move on
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

		print "Potential chords: ", [chord.__str__() for chord in chords]
		tensions = [chord.tension for chord in chords]

		moods = [chord.mood for chord in chords]

		func_values = [chord.hFunc[next_func] for chord in chords]

		tension_scores = [abs(curr_tension - t) for t in tensions]
		mood_scores = [abs(curr_mood - m) for m in moods]

		# Compute normalized scores, the larger the better
		tension_scores = NumberMinusList(1, tension_scores)
		tension_scores = listDivideNumber(tension_scores ,sum(tension_scores))
		print "Tension score: ", tension_scores

		mood_scores = NumberMinusList(1, mood_scores)
		mood_scores = listDivideNumber(tension_scores, sum(mood_scores))
		print "mood score: ", mood_scores

		func_values = listDivideNumber(func_values, sum(func_values))

		final_scores = addLists(addLists(tension_scores, mood_scores), func_values)
		final_scores = listDivideNumber(final_scores, sum(final_scores))
		print "Final score: ", final_scores

		r = rand()
		print "random value to choose:", r
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
		dic2 = {0:"Major",1:"Minor", 2:"Aug", 3:"Dim"}
		s+=dic2[self.type[0]]+" "
		dic3 = {0:"",1:"M7", 2:"m7", 3:"D7"}
		s+=dic3[self.type[1]]
		return s


I = Chord().init(0, [ChordType.Major, ChordType.Normal]).setHarmonicFunction(1,0,0,0).setMood(1.0).setBasicTension(0.1).setUnstable(False)
ii = Chord().init(2, [ChordType.Minor, ChordType.Normal]).setHarmonicFunction(0,0,1,0).setMood(0.4).setBasicTension(0.5).setUnstable(False)
iii = Chord().init(4, [ChordType.Minor, ChordType.Normal]).setHarmonicFunction(0.5,0.5,0,0).setMood(0.4).setBasicTension(0.5).setUnstable(False)
III = Chord().init(4, [ChordType.Major, ChordType.Major7]).setHarmonicFunction(0,1,0,0).setMood(0.5).setBasicTension(0.6).setUnstable(False)
III7 = Chord().init(4, [ChordType.Major, ChordType.Normal]).setHarmonicFunction(0.2,0.8,0.0).setMood(0.5).setBasicTension(0.7).setUnstable(True)
IV = Chord().init(5, [ChordType.Major, ChordType.Normal]).setHarmonicFunction(0,0,1,0).setMood(0.6).setBasicTension(0.3).setUnstable(False)
iv_ = Chord().init(5, [ChordType.Minor, ChordType.Normal]).setHarmonicFunction(0,0,0,1).setMood(0.5).setBasicTension(0.9).setUnstable(True)
V = Chord().init(7, [ChordType.Major, ChordType.Normal]).setHarmonicFunction(0,1,0,0).setMood(0.8).setBasicTension(0.4).setUnstable(False)
V7 = Chord().init(7, [ChordType.Major, ChordType.Major7]).setHarmonicFunction(0,1,0,0).setMood(0.7).setBasicTension(0.5).setUnstable(True)
vi = Chord().init(9, [ChordType.Minor, ChordType.Normal]).setHarmonicFunction(0.8,0,0.3,0).setMood(0.1).setBasicTension(0.2).setUnstable(False)

allchords = [I,ii,iii,III,III7,IV,iv_,V,V7,vi]


class ChordMain:
	def __init__(self):
		self.key=0
		self.current_mood=0.6
		self.current_tension=0.4
		self.current_chord=I
		self.current_func=ChordType.Tonic	

	def getNextPackedChord(self):
		self.current_chord, self.current_func = self.current_chord.next(
			                        self.current_chord, 
			                        self.current_tension, 
			                        self.current_mood, 
			                        self.current_func);
		return [self.key] + self.current_chord.getNotes(self.key) + [0]

	def setTension(self, t):
		self.current_tension = t

	def setMood(self, m):
		self.current_mood = m

c = ChordMain()
while True:
	print c.getNextPackedChord()
	print c.current_chord
	sleep(0.5)