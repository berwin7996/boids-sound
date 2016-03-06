import sys
from simpleOSC import initOSCServer, startOSCServer, closeOSC, setOSCHandler, initOSCClient, sendOSCMsg
from chordlogic import ChordMain

ip = "127.0.0.1"
server_boids_port = 9434
server_sound_port = 9435
client_port = 9436

chordmachine = ChordMain()

def run():
	try:
		initOSCClient(ip, client_port)

		# initOSCClient(ip, client_port)
		initOSCServer(ip, server_boids_port)
		setOSCHandler('/collision', col)
		startOSCServer()

		initOSCServer(ip, server_sound_port)
		setOSCHandler('/request', request)
		startOSCServer()

	except KeyboardInterrupt:
		closeOSC()

def col(addr, tags, data, source):
	print "got collision"
	print data
	if data[4]>15:
		chordmachine.current_tension = data[5] / 255.0
		print "Tension changed to", chordmachine.current_tension
		chordmachine.current_mood = 1.0 - (data[6]+data[7]) / (2*255.0)
		print "Mood changed_to", chordmachine.current_mood

def request(addr, tags, data, source):
	sendOSCMsg("/chord", chordmachine.getNextPackedChord())

run()