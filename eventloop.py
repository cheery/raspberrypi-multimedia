import pyudev, struct, time, select

def validate(dev):
    if dev.parent is None:
        return
    if dev.parent.get('NAME') is None:
        return
    if not dev.sys_name.startswith('event'):
        return
    if dev.device_node is None:
        return
    which = 'unknown'
    if dev.get('ID_INPUT_KEYBOARD') == '1':
        which = 'keyboard'
    if dev.get('ID_INPUT_MOUSE') == '1':
        which = 'mouse'
    if dev.get('ID_INPUT_JOYSTICK') == '1':
        which = 'joystick'
    if which == 'unknown':
        return
    return which, dev.device_node, dev.parent.get('NAME')

class EventEmitter(object):
    def __init__(self):
        self.outbound = []

    def send(self, key, *a):
        self.outbound.append((key, a))

    def push_events(self):
        for key, args in self.outbound:
            handler = getattr(self, 'on' + key)
            if callable(handler):
                handler(*args)
        self.outbound = []

class InputManager(EventEmitter):
    onadd = None
    onremove = None
    def __init__(self):
        EventEmitter.__init__(self)
        self.devicemap = {}
        context = pyudev.Context()
        for device in context.list_devices(subsystem='input'):
            info = validate(device)
            if info is not None:
                self.add_device(device, *info)
        self.monitor = monitor = pyudev.Monitor.from_netlink(context)
        monitor.filter_by(subsystem='input')
        monitor.start()

    @property
    def sources(self):
        return [self] + self.devicemap.values()

    def fileno(self):
        return self.monitor.fileno()

    def add_device(self, device, which, node, name):
        self.devicemap[node] = handle = EvDevInput(self, which, node, name)
        self.send('add', handle)

    def remove_device(self, device, which, node, name):
        handle = self.devicemap.pop(node, None)
        if handle is not None:
            handle.close()
            self.send('remove', handle)

    def on_read_ready(self):
        action, device = self.monitor.receive_device()
        info = validate(device)
        if action == 'add' and info is not None:
            self.add_device(device, *info)
        if action == 'remove' and info is not None:
            self.remove_device(device, *info)

evdev_fmt = "llHHi"
evdev_fmt_len = struct.calcsize(evdev_fmt)

class EvDevInput(EventEmitter):
    onevent = None
    def __init__(self, manager, which, node, name):
        EventEmitter.__init__(self)
        self.devicemap = {}
        self.manager = manager
        self.which = which
        self.node = node
        self.name = name
        self.fd = open(node)

    def fileno(self):
        return self.fd.fileno()

    def close(self):
        try:
            self.fd.close()
        except IOError, e:
            pass

    def __repr__(self):
        return "<%s %r>" % (self.which, self.name)

    def on_read_ready(self):
        if self.fd.closed:
            return
        try:
            data = self.fd.read(evdev_fmt_len)
            sec, usec, type, code, value = struct.unpack(evdev_fmt, data)
            timestamp = sec + float(usec) / 1000000
            self.emit(timestamp, type, code, value)
        except IOError, e:
            pass

    def emit(self, timestamp, type, code, value):
        self.send('event', timestamp, type, code, value)

class EventLoop(object):
    onidle = None
    def __init__(self, *subsystems):
        self.subsystems = list(subsystems)

    def handle_events(self, timeout, now):
        sources = []
        for subsystem in self.subsystems:
            sources.extend(subsystem.sources)
        for emitter in sources:
            emitter.push_events()
        ready0, ready1, ready2 = select.select(sources, (), (), max(0, timeout - (time.time() - now)))
        assert len(ready1) == 0
        for source in ready0:
            source.on_read_ready()

    def run(self, rate=1/60.0):
        accum = 0
        now = time.time()
        dt = 0.0
        while True:
            last = now
            timeout = rate

            if callable(self.onidle):
                self.onidle(dt)
            else:
                timeout = 10.0

            now = time.time()
            self.handle_events(timeout - (now - last), now)

            now = time.time()
            dt = (now - last)
