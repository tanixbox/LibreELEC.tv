import datetime
import xbmcgui
import xbmcaddon
import threading
import time
import sys
import os
import subprocess

addon = xbmcaddon.Addon(id='script.service.fd628')

class clockThreadClass(threading.Thread):
	def run(self):
		self.shutdown = False
		while not self.shutdown:
			vfdon = '/sys/class/leds/fd628_dev/led_on'
			vfdoff = '/sys/class/leds/fd628_dev/led_off'
			ledon = []
			ledoff = []
			play = pause = lanstate = lan = wifistate = wifi = ""
			usb_state = usb = ''
			play = xbmc.getCondVisibility('Player.Playing')
			pause = xbmc.getCondVisibility('Player.Paused')
			p = subprocess.Popen('blkid /dev/sd*', shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
			for line in p.stdout.readlines():
				usb_state += line
			retval = p.wait()
			if ( os.path.isfile('/sys/class/net/eth0/operstate')):
				lanstate = file('/sys/class/net/eth0/operstate', 'rb')
				lan = lanstate.read()
			if ( os.path.isfile('/sys/class/net/wlan0/operstate')):
				wifistate = file('/sys/class/net/wlan0/operstate', 'rb')
				wifi = wifistate.read()
			if len(usb_state) > 0 :
				ledon.append('usb')
			else:
				ledoff.append('usb')
			if (lan.find('up')>=0 or lan.find('unknown')>=0):
				ledon.append('eth')
			else:
				ledoff.append('eth')
			if (wifi.find('up')>=0):
				ledon.append('wifi')
			else:
				ledoff.append('wifi')
			if pause == True:
				ledon.append('pause')
			else:
				ledoff.append('pause')
			if play == True:
				ledon.append('play')
			else:
				ledoff.append('play')
			#print('led on',ledon)
			#print('led off',ledoff)

			for i in ledon:
				vfd = file(vfdon, "wb")
				vfd.write(i)
				vfd.flush()
			for j in ledoff:
				vfd = file(vfdoff, "wb")
				vfd.write(j)
				vfd.flush()
			time.sleep(0.5)

class ClockDialog:
	def __init__(self):
		self.clockThread = clockThreadClass()
		self.clockThread.start()

dialog = ClockDialog()
del dialog
del addon
