import sys
from simpleOSC import initOSCServer, startOSCServer, closeOSC, setOSCHandler, initOSCClient, sendOSCMsg
from chordlogic import ChordMain

ip = "127.0.0.1"
server_boids_port = 9434
server_sound_port = 9435
client_port = 9433

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

def request(addr, tags, data, source):
	sendOSCMsg("/chord", chordmachine.getNextPackedChord())

run()