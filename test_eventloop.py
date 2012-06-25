from eventloop import EventLoop, InputManager

devices = InputManager()

def onadd(device):
    print "[*] %r" % device
    def onevent(timestamp, type, code, value):
        print device, timestamp, type, code, value
    device.onevent = onevent

def onremove(device):
    print "[ ] %r" % device

devices.onadd = onadd
devices.onremove = onremove

eventloop = EventLoop(devices)
eventloop.run(1 / 60.0)
