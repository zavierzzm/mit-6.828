
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 00 19 10 f0       	push   $0xf0101900
f0100050:	e8 49 09 00 00       	call   f010099e <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 e5 06 00 00       	call   f0100760 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 1c 19 10 f0       	push   $0xf010191c
f0100087:	e8 12 09 00 00       	call   f010099e <cprintf>
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 a6 13 00 00       	call   f0101457 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 8f 04 00 00       	call   f0100545 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 37 19 10 f0       	push   $0xf0101937
f01000c3:	e8 d6 08 00 00       	call   f010099e <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>
f01000d4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d7:	83 ec 0c             	sub    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	e8 0e 07 00 00       	call   f01007ef <monitor>
f01000e1:	83 c4 10             	add    $0x10,%esp
f01000e4:	eb f1                	jmp    f01000d7 <i386_init+0x43>

f01000e6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e6:	55                   	push   %ebp
f01000e7:	89 e5                	mov    %esp,%ebp
f01000e9:	56                   	push   %esi
f01000ea:	53                   	push   %ebx
f01000eb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ee:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f01000f5:	75 37                	jne    f010012e <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000f7:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000fd:	fa                   	cli    
f01000fe:	fc                   	cld    

	va_start(ap, fmt);
f01000ff:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100102:	83 ec 04             	sub    $0x4,%esp
f0100105:	ff 75 0c             	pushl  0xc(%ebp)
f0100108:	ff 75 08             	pushl  0x8(%ebp)
f010010b:	68 52 19 10 f0       	push   $0xf0101952
f0100110:	e8 89 08 00 00       	call   f010099e <cprintf>
	vcprintf(fmt, ap);
f0100115:	83 c4 08             	add    $0x8,%esp
f0100118:	53                   	push   %ebx
f0100119:	56                   	push   %esi
f010011a:	e8 59 08 00 00       	call   f0100978 <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 8e 19 10 f0 	movl   $0xf010198e,(%esp)
f0100126:	e8 73 08 00 00       	call   f010099e <cprintf>
	va_end(ap);
f010012b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	83 ec 0c             	sub    $0xc,%esp
f0100131:	6a 00                	push   $0x0
f0100133:	e8 b7 06 00 00       	call   f01007ef <monitor>
f0100138:	83 c4 10             	add    $0x10,%esp
f010013b:	eb f1                	jmp    f010012e <_panic+0x48>

f010013d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013d:	55                   	push   %ebp
f010013e:	89 e5                	mov    %esp,%ebp
f0100140:	53                   	push   %ebx
f0100141:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100144:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100147:	ff 75 0c             	pushl  0xc(%ebp)
f010014a:	ff 75 08             	pushl  0x8(%ebp)
f010014d:	68 6a 19 10 f0       	push   $0xf010196a
f0100152:	e8 47 08 00 00       	call   f010099e <cprintf>
	vcprintf(fmt, ap);
f0100157:	83 c4 08             	add    $0x8,%esp
f010015a:	53                   	push   %ebx
f010015b:	ff 75 10             	pushl  0x10(%ebp)
f010015e:	e8 15 08 00 00       	call   f0100978 <vcprintf>
	cprintf("\n");
f0100163:	c7 04 24 8e 19 10 f0 	movl   $0xf010198e,(%esp)
f010016a:	e8 2f 08 00 00       	call   f010099e <cprintf>
	va_end(ap);
}
f010016f:	83 c4 10             	add    $0x10,%esp
f0100172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100175:	c9                   	leave  
f0100176:	c3                   	ret    

f0100177 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100177:	55                   	push   %ebp
f0100178:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010017f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100180:	a8 01                	test   $0x1,%al
f0100182:	74 0b                	je     f010018f <serial_proc_data+0x18>
f0100184:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100189:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010018a:	0f b6 c0             	movzbl %al,%eax
f010018d:	eb 05                	jmp    f0100194 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010018f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100194:	5d                   	pop    %ebp
f0100195:	c3                   	ret    

f0100196 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100196:	55                   	push   %ebp
f0100197:	89 e5                	mov    %esp,%ebp
f0100199:	53                   	push   %ebx
f010019a:	83 ec 04             	sub    $0x4,%esp
f010019d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010019f:	eb 2b                	jmp    f01001cc <cons_intr+0x36>
		if (c == 0)
f01001a1:	85 c0                	test   %eax,%eax
f01001a3:	74 27                	je     f01001cc <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a5:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ae:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001b4:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c0:	75 0a                	jne    f01001cc <cons_intr+0x36>
			cons.wpos = 0;
f01001c2:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001c9:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001cc:	ff d3                	call   *%ebx
f01001ce:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d1:	75 ce                	jne    f01001a1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001d3:	83 c4 04             	add    $0x4,%esp
f01001d6:	5b                   	pop    %ebx
f01001d7:	5d                   	pop    %ebp
f01001d8:	c3                   	ret    

f01001d9 <kbd_proc_data>:
f01001d9:	ba 64 00 00 00       	mov    $0x64,%edx
f01001de:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001df:	a8 01                	test   $0x1,%al
f01001e1:	0f 84 f0 00 00 00    	je     f01002d7 <kbd_proc_data+0xfe>
f01001e7:	ba 60 00 00 00       	mov    $0x60,%edx
f01001ec:	ec                   	in     (%dx),%al
f01001ed:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001ef:	3c e0                	cmp    $0xe0,%al
f01001f1:	75 0d                	jne    f0100200 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01001f3:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f01001fa:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001ff:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100200:	55                   	push   %ebp
f0100201:	89 e5                	mov    %esp,%ebp
f0100203:	53                   	push   %ebx
f0100204:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100207:	84 c0                	test   %al,%al
f0100209:	79 36                	jns    f0100241 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010020b:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100211:	89 cb                	mov    %ecx,%ebx
f0100213:	83 e3 40             	and    $0x40,%ebx
f0100216:	83 e0 7f             	and    $0x7f,%eax
f0100219:	85 db                	test   %ebx,%ebx
f010021b:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010021e:	0f b6 d2             	movzbl %dl,%edx
f0100221:	0f b6 82 e0 1a 10 f0 	movzbl -0xfefe520(%edx),%eax
f0100228:	83 c8 40             	or     $0x40,%eax
f010022b:	0f b6 c0             	movzbl %al,%eax
f010022e:	f7 d0                	not    %eax
f0100230:	21 c8                	and    %ecx,%eax
f0100232:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f0100237:	b8 00 00 00 00       	mov    $0x0,%eax
f010023c:	e9 9e 00 00 00       	jmp    f01002df <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100241:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100247:	f6 c1 40             	test   $0x40,%cl
f010024a:	74 0e                	je     f010025a <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010024c:	83 c8 80             	or     $0xffffff80,%eax
f010024f:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100251:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100254:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f010025a:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010025d:	0f b6 82 e0 1a 10 f0 	movzbl -0xfefe520(%edx),%eax
f0100264:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f010026a:	0f b6 8a e0 19 10 f0 	movzbl -0xfefe620(%edx),%ecx
f0100271:	31 c8                	xor    %ecx,%eax
f0100273:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100278:	89 c1                	mov    %eax,%ecx
f010027a:	83 e1 03             	and    $0x3,%ecx
f010027d:	8b 0c 8d c0 19 10 f0 	mov    -0xfefe640(,%ecx,4),%ecx
f0100284:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100288:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010028b:	a8 08                	test   $0x8,%al
f010028d:	74 1b                	je     f01002aa <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f010028f:	89 da                	mov    %ebx,%edx
f0100291:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100294:	83 f9 19             	cmp    $0x19,%ecx
f0100297:	77 05                	ja     f010029e <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100299:	83 eb 20             	sub    $0x20,%ebx
f010029c:	eb 0c                	jmp    f01002aa <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f010029e:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002a1:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002a4:	83 fa 19             	cmp    $0x19,%edx
f01002a7:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002aa:	f7 d0                	not    %eax
f01002ac:	a8 06                	test   $0x6,%al
f01002ae:	75 2d                	jne    f01002dd <kbd_proc_data+0x104>
f01002b0:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002b6:	75 25                	jne    f01002dd <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01002b8:	83 ec 0c             	sub    $0xc,%esp
f01002bb:	68 84 19 10 f0       	push   $0xf0101984
f01002c0:	e8 d9 06 00 00       	call   f010099e <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002c5:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ca:	b8 03 00 00 00       	mov    $0x3,%eax
f01002cf:	ee                   	out    %al,(%dx)
f01002d0:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002d3:	89 d8                	mov    %ebx,%eax
f01002d5:	eb 08                	jmp    f01002df <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002dc:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002dd:	89 d8                	mov    %ebx,%eax
}
f01002df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002e2:	c9                   	leave  
f01002e3:	c3                   	ret    

f01002e4 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002e4:	55                   	push   %ebp
f01002e5:	89 e5                	mov    %esp,%ebp
f01002e7:	57                   	push   %edi
f01002e8:	56                   	push   %esi
f01002e9:	53                   	push   %ebx
f01002ea:	83 ec 1c             	sub    $0x1c,%esp
f01002ed:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002ef:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f4:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002f9:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002fe:	eb 09                	jmp    f0100309 <cons_putc+0x25>
f0100300:	89 ca                	mov    %ecx,%edx
f0100302:	ec                   	in     (%dx),%al
f0100303:	ec                   	in     (%dx),%al
f0100304:	ec                   	in     (%dx),%al
f0100305:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100306:	83 c3 01             	add    $0x1,%ebx
f0100309:	89 f2                	mov    %esi,%edx
f010030b:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010030c:	a8 20                	test   $0x20,%al
f010030e:	75 08                	jne    f0100318 <cons_putc+0x34>
f0100310:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100316:	7e e8                	jle    f0100300 <cons_putc+0x1c>
f0100318:	89 f8                	mov    %edi,%eax
f010031a:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010031d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100322:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100323:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100328:	be 79 03 00 00       	mov    $0x379,%esi
f010032d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100332:	eb 09                	jmp    f010033d <cons_putc+0x59>
f0100334:	89 ca                	mov    %ecx,%edx
f0100336:	ec                   	in     (%dx),%al
f0100337:	ec                   	in     (%dx),%al
f0100338:	ec                   	in     (%dx),%al
f0100339:	ec                   	in     (%dx),%al
f010033a:	83 c3 01             	add    $0x1,%ebx
f010033d:	89 f2                	mov    %esi,%edx
f010033f:	ec                   	in     (%dx),%al
f0100340:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100346:	7f 04                	jg     f010034c <cons_putc+0x68>
f0100348:	84 c0                	test   %al,%al
f010034a:	79 e8                	jns    f0100334 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010034c:	ba 78 03 00 00       	mov    $0x378,%edx
f0100351:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100355:	ee                   	out    %al,(%dx)
f0100356:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010035b:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100360:	ee                   	out    %al,(%dx)
f0100361:	b8 08 00 00 00       	mov    $0x8,%eax
f0100366:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100367:	89 fa                	mov    %edi,%edx
f0100369:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010036f:	89 f8                	mov    %edi,%eax
f0100371:	80 cc 07             	or     $0x7,%ah
f0100374:	85 d2                	test   %edx,%edx
f0100376:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100379:	89 f8                	mov    %edi,%eax
f010037b:	0f b6 c0             	movzbl %al,%eax
f010037e:	83 f8 09             	cmp    $0x9,%eax
f0100381:	74 74                	je     f01003f7 <cons_putc+0x113>
f0100383:	83 f8 09             	cmp    $0x9,%eax
f0100386:	7f 0a                	jg     f0100392 <cons_putc+0xae>
f0100388:	83 f8 08             	cmp    $0x8,%eax
f010038b:	74 14                	je     f01003a1 <cons_putc+0xbd>
f010038d:	e9 99 00 00 00       	jmp    f010042b <cons_putc+0x147>
f0100392:	83 f8 0a             	cmp    $0xa,%eax
f0100395:	74 3a                	je     f01003d1 <cons_putc+0xed>
f0100397:	83 f8 0d             	cmp    $0xd,%eax
f010039a:	74 3d                	je     f01003d9 <cons_putc+0xf5>
f010039c:	e9 8a 00 00 00       	jmp    f010042b <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003a1:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003a8:	66 85 c0             	test   %ax,%ax
f01003ab:	0f 84 e6 00 00 00    	je     f0100497 <cons_putc+0x1b3>
			crt_pos--;
f01003b1:	83 e8 01             	sub    $0x1,%eax
f01003b4:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003ba:	0f b7 c0             	movzwl %ax,%eax
f01003bd:	66 81 e7 00 ff       	and    $0xff00,%di
f01003c2:	83 cf 20             	or     $0x20,%edi
f01003c5:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003cb:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003cf:	eb 78                	jmp    f0100449 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003d1:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f01003d8:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003d9:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003e0:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003e6:	c1 e8 16             	shr    $0x16,%eax
f01003e9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003ec:	c1 e0 04             	shl    $0x4,%eax
f01003ef:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f01003f5:	eb 52                	jmp    f0100449 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01003fc:	e8 e3 fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f0100401:	b8 20 00 00 00       	mov    $0x20,%eax
f0100406:	e8 d9 fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f010040b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100410:	e8 cf fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f0100415:	b8 20 00 00 00       	mov    $0x20,%eax
f010041a:	e8 c5 fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f010041f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100424:	e8 bb fe ff ff       	call   f01002e4 <cons_putc>
f0100429:	eb 1e                	jmp    f0100449 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010042b:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100432:	8d 50 01             	lea    0x1(%eax),%edx
f0100435:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f010043c:	0f b7 c0             	movzwl %ax,%eax
f010043f:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100445:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100449:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f0100450:	cf 07 
f0100452:	76 43                	jbe    f0100497 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100454:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100459:	83 ec 04             	sub    $0x4,%esp
f010045c:	68 00 0f 00 00       	push   $0xf00
f0100461:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100467:	52                   	push   %edx
f0100468:	50                   	push   %eax
f0100469:	e8 36 10 00 00       	call   f01014a4 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010046e:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100474:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010047a:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100480:	83 c4 10             	add    $0x10,%esp
f0100483:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100488:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010048b:	39 d0                	cmp    %edx,%eax
f010048d:	75 f4                	jne    f0100483 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010048f:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f0100496:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100497:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f010049d:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004a2:	89 ca                	mov    %ecx,%edx
f01004a4:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004a5:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01004ac:	8d 71 01             	lea    0x1(%ecx),%esi
f01004af:	89 d8                	mov    %ebx,%eax
f01004b1:	66 c1 e8 08          	shr    $0x8,%ax
f01004b5:	89 f2                	mov    %esi,%edx
f01004b7:	ee                   	out    %al,(%dx)
f01004b8:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004bd:	89 ca                	mov    %ecx,%edx
f01004bf:	ee                   	out    %al,(%dx)
f01004c0:	89 d8                	mov    %ebx,%eax
f01004c2:	89 f2                	mov    %esi,%edx
f01004c4:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004c8:	5b                   	pop    %ebx
f01004c9:	5e                   	pop    %esi
f01004ca:	5f                   	pop    %edi
f01004cb:	5d                   	pop    %ebp
f01004cc:	c3                   	ret    

f01004cd <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004cd:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004d4:	74 11                	je     f01004e7 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004d6:	55                   	push   %ebp
f01004d7:	89 e5                	mov    %esp,%ebp
f01004d9:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004dc:	b8 77 01 10 f0       	mov    $0xf0100177,%eax
f01004e1:	e8 b0 fc ff ff       	call   f0100196 <cons_intr>
}
f01004e6:	c9                   	leave  
f01004e7:	f3 c3                	repz ret 

f01004e9 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004e9:	55                   	push   %ebp
f01004ea:	89 e5                	mov    %esp,%ebp
f01004ec:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004ef:	b8 d9 01 10 f0       	mov    $0xf01001d9,%eax
f01004f4:	e8 9d fc ff ff       	call   f0100196 <cons_intr>
}
f01004f9:	c9                   	leave  
f01004fa:	c3                   	ret    

f01004fb <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004fb:	55                   	push   %ebp
f01004fc:	89 e5                	mov    %esp,%ebp
f01004fe:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100501:	e8 c7 ff ff ff       	call   f01004cd <serial_intr>
	kbd_intr();
f0100506:	e8 de ff ff ff       	call   f01004e9 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010050b:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f0100510:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f0100516:	74 26                	je     f010053e <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100518:	8d 50 01             	lea    0x1(%eax),%edx
f010051b:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f0100521:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100528:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010052a:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100530:	75 11                	jne    f0100543 <cons_getc+0x48>
			cons.rpos = 0;
f0100532:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100539:	00 00 00 
f010053c:	eb 05                	jmp    f0100543 <cons_getc+0x48>
		return c;
	}
	return 0;
f010053e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100543:	c9                   	leave  
f0100544:	c3                   	ret    

f0100545 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100545:	55                   	push   %ebp
f0100546:	89 e5                	mov    %esp,%ebp
f0100548:	57                   	push   %edi
f0100549:	56                   	push   %esi
f010054a:	53                   	push   %ebx
f010054b:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010054e:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100555:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010055c:	5a a5 
	if (*cp != 0xA55A) {
f010055e:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100565:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100569:	74 11                	je     f010057c <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010056b:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f0100572:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100575:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010057a:	eb 16                	jmp    f0100592 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010057c:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100583:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f010058a:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010058d:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100592:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f0100598:	b8 0e 00 00 00       	mov    $0xe,%eax
f010059d:	89 fa                	mov    %edi,%edx
f010059f:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005a0:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005a3:	89 da                	mov    %ebx,%edx
f01005a5:	ec                   	in     (%dx),%al
f01005a6:	0f b6 c8             	movzbl %al,%ecx
f01005a9:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ac:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005b1:	89 fa                	mov    %edi,%edx
f01005b3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b4:	89 da                	mov    %ebx,%edx
f01005b6:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005b7:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f01005bd:	0f b6 c0             	movzbl %al,%eax
f01005c0:	09 c8                	or     %ecx,%eax
f01005c2:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005c8:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01005d2:	89 f2                	mov    %esi,%edx
f01005d4:	ee                   	out    %al,(%dx)
f01005d5:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005da:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005df:	ee                   	out    %al,(%dx)
f01005e0:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005e5:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005ea:	89 da                	mov    %ebx,%edx
f01005ec:	ee                   	out    %al,(%dx)
f01005ed:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01005f7:	ee                   	out    %al,(%dx)
f01005f8:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005fd:	b8 03 00 00 00       	mov    $0x3,%eax
f0100602:	ee                   	out    %al,(%dx)
f0100603:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100608:	b8 00 00 00 00       	mov    $0x0,%eax
f010060d:	ee                   	out    %al,(%dx)
f010060e:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100613:	b8 01 00 00 00       	mov    $0x1,%eax
f0100618:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100619:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010061e:	ec                   	in     (%dx),%al
f010061f:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100621:	3c ff                	cmp    $0xff,%al
f0100623:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f010062a:	89 f2                	mov    %esi,%edx
f010062c:	ec                   	in     (%dx),%al
f010062d:	89 da                	mov    %ebx,%edx
f010062f:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100630:	80 f9 ff             	cmp    $0xff,%cl
f0100633:	75 10                	jne    f0100645 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100635:	83 ec 0c             	sub    $0xc,%esp
f0100638:	68 90 19 10 f0       	push   $0xf0101990
f010063d:	e8 5c 03 00 00       	call   f010099e <cprintf>
f0100642:	83 c4 10             	add    $0x10,%esp
}
f0100645:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100648:	5b                   	pop    %ebx
f0100649:	5e                   	pop    %esi
f010064a:	5f                   	pop    %edi
f010064b:	5d                   	pop    %ebp
f010064c:	c3                   	ret    

f010064d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010064d:	55                   	push   %ebp
f010064e:	89 e5                	mov    %esp,%ebp
f0100650:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100653:	8b 45 08             	mov    0x8(%ebp),%eax
f0100656:	e8 89 fc ff ff       	call   f01002e4 <cons_putc>
}
f010065b:	c9                   	leave  
f010065c:	c3                   	ret    

f010065d <getchar>:

int
getchar(void)
{
f010065d:	55                   	push   %ebp
f010065e:	89 e5                	mov    %esp,%ebp
f0100660:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100663:	e8 93 fe ff ff       	call   f01004fb <cons_getc>
f0100668:	85 c0                	test   %eax,%eax
f010066a:	74 f7                	je     f0100663 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010066c:	c9                   	leave  
f010066d:	c3                   	ret    

f010066e <iscons>:

int
iscons(int fdnum)
{
f010066e:	55                   	push   %ebp
f010066f:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100671:	b8 01 00 00 00       	mov    $0x1,%eax
f0100676:	5d                   	pop    %ebp
f0100677:	c3                   	ret    

f0100678 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100678:	55                   	push   %ebp
f0100679:	89 e5                	mov    %esp,%ebp
f010067b:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010067e:	68 e0 1b 10 f0       	push   $0xf0101be0
f0100683:	68 fe 1b 10 f0       	push   $0xf0101bfe
f0100688:	68 03 1c 10 f0       	push   $0xf0101c03
f010068d:	e8 0c 03 00 00       	call   f010099e <cprintf>
f0100692:	83 c4 0c             	add    $0xc,%esp
f0100695:	68 a8 1c 10 f0       	push   $0xf0101ca8
f010069a:	68 0c 1c 10 f0       	push   $0xf0101c0c
f010069f:	68 03 1c 10 f0       	push   $0xf0101c03
f01006a4:	e8 f5 02 00 00       	call   f010099e <cprintf>
	return 0;
}
f01006a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01006ae:	c9                   	leave  
f01006af:	c3                   	ret    

f01006b0 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006b0:	55                   	push   %ebp
f01006b1:	89 e5                	mov    %esp,%ebp
f01006b3:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006b6:	68 15 1c 10 f0       	push   $0xf0101c15
f01006bb:	e8 de 02 00 00       	call   f010099e <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006c0:	83 c4 08             	add    $0x8,%esp
f01006c3:	68 0c 00 10 00       	push   $0x10000c
f01006c8:	68 d0 1c 10 f0       	push   $0xf0101cd0
f01006cd:	e8 cc 02 00 00       	call   f010099e <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006d2:	83 c4 0c             	add    $0xc,%esp
f01006d5:	68 0c 00 10 00       	push   $0x10000c
f01006da:	68 0c 00 10 f0       	push   $0xf010000c
f01006df:	68 f8 1c 10 f0       	push   $0xf0101cf8
f01006e4:	e8 b5 02 00 00       	call   f010099e <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006e9:	83 c4 0c             	add    $0xc,%esp
f01006ec:	68 e1 18 10 00       	push   $0x1018e1
f01006f1:	68 e1 18 10 f0       	push   $0xf01018e1
f01006f6:	68 1c 1d 10 f0       	push   $0xf0101d1c
f01006fb:	e8 9e 02 00 00       	call   f010099e <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100700:	83 c4 0c             	add    $0xc,%esp
f0100703:	68 00 23 11 00       	push   $0x112300
f0100708:	68 00 23 11 f0       	push   $0xf0112300
f010070d:	68 40 1d 10 f0       	push   $0xf0101d40
f0100712:	e8 87 02 00 00       	call   f010099e <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100717:	83 c4 0c             	add    $0xc,%esp
f010071a:	68 44 29 11 00       	push   $0x112944
f010071f:	68 44 29 11 f0       	push   $0xf0112944
f0100724:	68 64 1d 10 f0       	push   $0xf0101d64
f0100729:	e8 70 02 00 00       	call   f010099e <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010072e:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f0100733:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100738:	83 c4 08             	add    $0x8,%esp
f010073b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100740:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100746:	85 c0                	test   %eax,%eax
f0100748:	0f 48 c2             	cmovs  %edx,%eax
f010074b:	c1 f8 0a             	sar    $0xa,%eax
f010074e:	50                   	push   %eax
f010074f:	68 88 1d 10 f0       	push   $0xf0101d88
f0100754:	e8 45 02 00 00       	call   f010099e <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100759:	b8 00 00 00 00       	mov    $0x0,%eax
f010075e:	c9                   	leave  
f010075f:	c3                   	ret    

f0100760 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100760:	55                   	push   %ebp
f0100761:	89 e5                	mov    %esp,%ebp
f0100763:	57                   	push   %edi
f0100764:	56                   	push   %esi
f0100765:	53                   	push   %ebx
f0100766:	83 ec 48             	sub    $0x48,%esp
	uint32_t old_ebp;
	uint32_t eip;
	uint32_t paras[5];
	int i;
	
	cprintf("Stack backtrace:\n");
f0100769:	68 2e 1c 10 f0       	push   $0xf0101c2e
f010076e:	e8 2b 02 00 00       	call   f010099e <cprintf>

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100773:	89 ea                	mov    %ebp,%edx
	ebp = (uint32_t*)read_ebp();
	while (ebp != 0) {
f0100775:	83 c4 10             	add    $0x10,%esp
		eip = (uint32_t)(*(ebp + 1));
		for (i = 0; i < 5; i++)
			paras[i] = (uint32_t)(*(ebp + 2 + i));
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, paras[0], paras[1], paras[2], paras[3], paras[4]);
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f0100778:	8d 7d bc             	lea    -0x44(%ebp),%edi
	uint32_t paras[5];
	int i;
	
	cprintf("Stack backtrace:\n");
	ebp = (uint32_t*)read_ebp();
	while (ebp != 0) {
f010077b:	eb 61                	jmp    f01007de <mon_backtrace+0x7e>
		old_ebp = (uint32_t)(*ebp);
f010077d:	8b 32                	mov    (%edx),%esi
		eip = (uint32_t)(*(ebp + 1));
f010077f:	8b 5a 04             	mov    0x4(%edx),%ebx
		for (i = 0; i < 5; i++)
f0100782:	b8 00 00 00 00       	mov    $0x0,%eax
			paras[i] = (uint32_t)(*(ebp + 2 + i));
f0100787:	8b 4c 82 08          	mov    0x8(%edx,%eax,4),%ecx
f010078b:	89 4c 85 d4          	mov    %ecx,-0x2c(%ebp,%eax,4)
	cprintf("Stack backtrace:\n");
	ebp = (uint32_t*)read_ebp();
	while (ebp != 0) {
		old_ebp = (uint32_t)(*ebp);
		eip = (uint32_t)(*(ebp + 1));
		for (i = 0; i < 5; i++)
f010078f:	83 c0 01             	add    $0x1,%eax
f0100792:	83 f8 05             	cmp    $0x5,%eax
f0100795:	75 f0                	jne    f0100787 <mon_backtrace+0x27>
			paras[i] = (uint32_t)(*(ebp + 2 + i));
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, paras[0], paras[1], paras[2], paras[3], paras[4]);
f0100797:	ff 75 e4             	pushl  -0x1c(%ebp)
f010079a:	ff 75 e0             	pushl  -0x20(%ebp)
f010079d:	ff 75 dc             	pushl  -0x24(%ebp)
f01007a0:	ff 75 d8             	pushl  -0x28(%ebp)
f01007a3:	ff 75 d4             	pushl  -0x2c(%ebp)
f01007a6:	53                   	push   %ebx
f01007a7:	52                   	push   %edx
f01007a8:	68 b4 1d 10 f0       	push   $0xf0101db4
f01007ad:	e8 ec 01 00 00       	call   f010099e <cprintf>
		struct Eipdebuginfo info;
		debuginfo_eip(eip, &info);
f01007b2:	83 c4 18             	add    $0x18,%esp
f01007b5:	57                   	push   %edi
f01007b6:	53                   	push   %ebx
f01007b7:	e8 ec 02 00 00       	call   f0100aa8 <debuginfo_eip>
		cprintf("%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
f01007bc:	83 c4 08             	add    $0x8,%esp
f01007bf:	2b 5d cc             	sub    -0x34(%ebp),%ebx
f01007c2:	53                   	push   %ebx
f01007c3:	ff 75 c4             	pushl  -0x3c(%ebp)
f01007c6:	ff 75 c8             	pushl  -0x38(%ebp)
f01007c9:	ff 75 c0             	pushl  -0x40(%ebp)
f01007cc:	ff 75 bc             	pushl  -0x44(%ebp)
f01007cf:	68 40 1c 10 f0       	push   $0xf0101c40
f01007d4:	e8 c5 01 00 00       	call   f010099e <cprintf>
		ebp = (uint32_t*)old_ebp;
f01007d9:	89 f2                	mov    %esi,%edx
f01007db:	83 c4 20             	add    $0x20,%esp
	uint32_t paras[5];
	int i;
	
	cprintf("Stack backtrace:\n");
	ebp = (uint32_t*)read_ebp();
	while (ebp != 0) {
f01007de:	85 d2                	test   %edx,%edx
f01007e0:	75 9b                	jne    f010077d <mon_backtrace+0x1d>
		debuginfo_eip(eip, &info);
		cprintf("%s:%d: %.*s+%d\n", info.eip_file, info.eip_line, info.eip_fn_namelen, info.eip_fn_name, eip - info.eip_fn_addr);
		ebp = (uint32_t*)old_ebp;
	}
	return 0;
}
f01007e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01007e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01007ea:	5b                   	pop    %ebx
f01007eb:	5e                   	pop    %esi
f01007ec:	5f                   	pop    %edi
f01007ed:	5d                   	pop    %ebp
f01007ee:	c3                   	ret    

f01007ef <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01007ef:	55                   	push   %ebp
f01007f0:	89 e5                	mov    %esp,%ebp
f01007f2:	57                   	push   %edi
f01007f3:	56                   	push   %esi
f01007f4:	53                   	push   %ebx
f01007f5:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	int x = 1, y = 3, z = 4;
	unsigned int i = 0x00646c72;
f01007f8:	c7 45 e4 72 6c 64 00 	movl   $0x646c72,-0x1c(%ebp)
	cprintf("x %d, y %x, z%d\n", x, y, z);
f01007ff:	6a 04                	push   $0x4
f0100801:	6a 03                	push   $0x3
f0100803:	6a 01                	push   $0x1
f0100805:	68 50 1c 10 f0       	push   $0xf0101c50
f010080a:	e8 8f 01 00 00       	call   f010099e <cprintf>
	cprintf("H%x Wo%s\n", 57616, &i);
f010080f:	83 c4 0c             	add    $0xc,%esp
f0100812:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100815:	50                   	push   %eax
f0100816:	68 10 e1 00 00       	push   $0xe110
f010081b:	68 61 1c 10 f0       	push   $0xf0101c61
f0100820:	e8 79 01 00 00       	call   f010099e <cprintf>

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100825:	c7 04 24 ec 1d 10 f0 	movl   $0xf0101dec,(%esp)
f010082c:	e8 6d 01 00 00       	call   f010099e <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100831:	c7 04 24 10 1e 10 f0 	movl   $0xf0101e10,(%esp)
f0100838:	e8 61 01 00 00       	call   f010099e <cprintf>
f010083d:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100840:	83 ec 0c             	sub    $0xc,%esp
f0100843:	68 6b 1c 10 f0       	push   $0xf0101c6b
f0100848:	e8 b3 09 00 00       	call   f0101200 <readline>
f010084d:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010084f:	83 c4 10             	add    $0x10,%esp
f0100852:	85 c0                	test   %eax,%eax
f0100854:	74 ea                	je     f0100840 <monitor+0x51>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100856:	c7 45 a4 00 00 00 00 	movl   $0x0,-0x5c(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010085d:	be 00 00 00 00       	mov    $0x0,%esi
f0100862:	eb 0a                	jmp    f010086e <monitor+0x7f>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100864:	c6 03 00             	movb   $0x0,(%ebx)
f0100867:	89 f7                	mov    %esi,%edi
f0100869:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010086c:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010086e:	0f b6 03             	movzbl (%ebx),%eax
f0100871:	84 c0                	test   %al,%al
f0100873:	74 63                	je     f01008d8 <monitor+0xe9>
f0100875:	83 ec 08             	sub    $0x8,%esp
f0100878:	0f be c0             	movsbl %al,%eax
f010087b:	50                   	push   %eax
f010087c:	68 6f 1c 10 f0       	push   $0xf0101c6f
f0100881:	e8 94 0b 00 00       	call   f010141a <strchr>
f0100886:	83 c4 10             	add    $0x10,%esp
f0100889:	85 c0                	test   %eax,%eax
f010088b:	75 d7                	jne    f0100864 <monitor+0x75>
			*buf++ = 0;
		if (*buf == 0)
f010088d:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100890:	74 46                	je     f01008d8 <monitor+0xe9>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100892:	83 fe 0f             	cmp    $0xf,%esi
f0100895:	75 14                	jne    f01008ab <monitor+0xbc>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100897:	83 ec 08             	sub    $0x8,%esp
f010089a:	6a 10                	push   $0x10
f010089c:	68 74 1c 10 f0       	push   $0xf0101c74
f01008a1:	e8 f8 00 00 00       	call   f010099e <cprintf>
f01008a6:	83 c4 10             	add    $0x10,%esp
f01008a9:	eb 95                	jmp    f0100840 <monitor+0x51>
			return 0;
		}
		argv[argc++] = buf;
f01008ab:	8d 7e 01             	lea    0x1(%esi),%edi
f01008ae:	89 5c b5 a4          	mov    %ebx,-0x5c(%ebp,%esi,4)
f01008b2:	eb 03                	jmp    f01008b7 <monitor+0xc8>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008b4:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008b7:	0f b6 03             	movzbl (%ebx),%eax
f01008ba:	84 c0                	test   %al,%al
f01008bc:	74 ae                	je     f010086c <monitor+0x7d>
f01008be:	83 ec 08             	sub    $0x8,%esp
f01008c1:	0f be c0             	movsbl %al,%eax
f01008c4:	50                   	push   %eax
f01008c5:	68 6f 1c 10 f0       	push   $0xf0101c6f
f01008ca:	e8 4b 0b 00 00       	call   f010141a <strchr>
f01008cf:	83 c4 10             	add    $0x10,%esp
f01008d2:	85 c0                	test   %eax,%eax
f01008d4:	74 de                	je     f01008b4 <monitor+0xc5>
f01008d6:	eb 94                	jmp    f010086c <monitor+0x7d>
			buf++;
	}
	argv[argc] = 0;
f01008d8:	c7 44 b5 a4 00 00 00 	movl   $0x0,-0x5c(%ebp,%esi,4)
f01008df:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01008e0:	85 f6                	test   %esi,%esi
f01008e2:	0f 84 58 ff ff ff    	je     f0100840 <monitor+0x51>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01008e8:	83 ec 08             	sub    $0x8,%esp
f01008eb:	68 fe 1b 10 f0       	push   $0xf0101bfe
f01008f0:	ff 75 a4             	pushl  -0x5c(%ebp)
f01008f3:	e8 c4 0a 00 00       	call   f01013bc <strcmp>
f01008f8:	83 c4 10             	add    $0x10,%esp
f01008fb:	85 c0                	test   %eax,%eax
f01008fd:	74 1e                	je     f010091d <monitor+0x12e>
f01008ff:	83 ec 08             	sub    $0x8,%esp
f0100902:	68 0c 1c 10 f0       	push   $0xf0101c0c
f0100907:	ff 75 a4             	pushl  -0x5c(%ebp)
f010090a:	e8 ad 0a 00 00       	call   f01013bc <strcmp>
f010090f:	83 c4 10             	add    $0x10,%esp
f0100912:	85 c0                	test   %eax,%eax
f0100914:	75 2f                	jne    f0100945 <monitor+0x156>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100916:	b8 01 00 00 00       	mov    $0x1,%eax
f010091b:	eb 05                	jmp    f0100922 <monitor+0x133>
		if (strcmp(argv[0], commands[i].name) == 0)
f010091d:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100922:	83 ec 04             	sub    $0x4,%esp
f0100925:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100928:	01 d0                	add    %edx,%eax
f010092a:	ff 75 08             	pushl  0x8(%ebp)
f010092d:	8d 4d a4             	lea    -0x5c(%ebp),%ecx
f0100930:	51                   	push   %ecx
f0100931:	56                   	push   %esi
f0100932:	ff 14 85 40 1e 10 f0 	call   *-0xfefe1c0(,%eax,4)
	cprintf("Type 'help' for a list of commands.\n");

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100939:	83 c4 10             	add    $0x10,%esp
f010093c:	85 c0                	test   %eax,%eax
f010093e:	78 1d                	js     f010095d <monitor+0x16e>
f0100940:	e9 fb fe ff ff       	jmp    f0100840 <monitor+0x51>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100945:	83 ec 08             	sub    $0x8,%esp
f0100948:	ff 75 a4             	pushl  -0x5c(%ebp)
f010094b:	68 91 1c 10 f0       	push   $0xf0101c91
f0100950:	e8 49 00 00 00       	call   f010099e <cprintf>
f0100955:	83 c4 10             	add    $0x10,%esp
f0100958:	e9 e3 fe ff ff       	jmp    f0100840 <monitor+0x51>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010095d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100960:	5b                   	pop    %ebx
f0100961:	5e                   	pop    %esi
f0100962:	5f                   	pop    %edi
f0100963:	5d                   	pop    %ebp
f0100964:	c3                   	ret    

f0100965 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100965:	55                   	push   %ebp
f0100966:	89 e5                	mov    %esp,%ebp
f0100968:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010096b:	ff 75 08             	pushl  0x8(%ebp)
f010096e:	e8 da fc ff ff       	call   f010064d <cputchar>
	*cnt++;
}
f0100973:	83 c4 10             	add    $0x10,%esp
f0100976:	c9                   	leave  
f0100977:	c3                   	ret    

f0100978 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0100978:	55                   	push   %ebp
f0100979:	89 e5                	mov    %esp,%ebp
f010097b:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010097e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100985:	ff 75 0c             	pushl  0xc(%ebp)
f0100988:	ff 75 08             	pushl  0x8(%ebp)
f010098b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010098e:	50                   	push   %eax
f010098f:	68 65 09 10 f0       	push   $0xf0100965
f0100994:	e8 52 04 00 00       	call   f0100deb <vprintfmt>
	return cnt;
}
f0100999:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010099c:	c9                   	leave  
f010099d:	c3                   	ret    

f010099e <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010099e:	55                   	push   %ebp
f010099f:	89 e5                	mov    %esp,%ebp
f01009a1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01009a4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01009a7:	50                   	push   %eax
f01009a8:	ff 75 08             	pushl  0x8(%ebp)
f01009ab:	e8 c8 ff ff ff       	call   f0100978 <vcprintf>
	va_end(ap);

	return cnt;
}
f01009b0:	c9                   	leave  
f01009b1:	c3                   	ret    

f01009b2 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01009b2:	55                   	push   %ebp
f01009b3:	89 e5                	mov    %esp,%ebp
f01009b5:	57                   	push   %edi
f01009b6:	56                   	push   %esi
f01009b7:	53                   	push   %ebx
f01009b8:	83 ec 14             	sub    $0x14,%esp
f01009bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01009be:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01009c1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01009c4:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01009c7:	8b 1a                	mov    (%edx),%ebx
f01009c9:	8b 01                	mov    (%ecx),%eax
f01009cb:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009ce:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01009d5:	eb 7f                	jmp    f0100a56 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01009d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01009da:	01 d8                	add    %ebx,%eax
f01009dc:	89 c6                	mov    %eax,%esi
f01009de:	c1 ee 1f             	shr    $0x1f,%esi
f01009e1:	01 c6                	add    %eax,%esi
f01009e3:	d1 fe                	sar    %esi
f01009e5:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01009e8:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01009eb:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01009ee:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009f0:	eb 03                	jmp    f01009f5 <stab_binsearch+0x43>
			m--;
f01009f2:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01009f5:	39 c3                	cmp    %eax,%ebx
f01009f7:	7f 0d                	jg     f0100a06 <stab_binsearch+0x54>
f01009f9:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01009fd:	83 ea 0c             	sub    $0xc,%edx
f0100a00:	39 f9                	cmp    %edi,%ecx
f0100a02:	75 ee                	jne    f01009f2 <stab_binsearch+0x40>
f0100a04:	eb 05                	jmp    f0100a0b <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100a06:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100a09:	eb 4b                	jmp    f0100a56 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100a0b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a0e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a11:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100a15:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a18:	76 11                	jbe    f0100a2b <stab_binsearch+0x79>
			*region_left = m;
f0100a1a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100a1d:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100a1f:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a22:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a29:	eb 2b                	jmp    f0100a56 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a2b:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a2e:	73 14                	jae    f0100a44 <stab_binsearch+0x92>
			*region_right = m - 1;
f0100a30:	83 e8 01             	sub    $0x1,%eax
f0100a33:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a36:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a39:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a3b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a42:	eb 12                	jmp    f0100a56 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a44:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a47:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a49:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a4d:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a4f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a56:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a59:	0f 8e 78 ff ff ff    	jle    f01009d7 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a5f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100a63:	75 0f                	jne    f0100a74 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100a65:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a68:	8b 00                	mov    (%eax),%eax
f0100a6a:	83 e8 01             	sub    $0x1,%eax
f0100a6d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a70:	89 06                	mov    %eax,(%esi)
f0100a72:	eb 2c                	jmp    f0100aa0 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a74:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100a77:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100a79:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a7c:	8b 0e                	mov    (%esi),%ecx
f0100a7e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a81:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100a84:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a87:	eb 03                	jmp    f0100a8c <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100a89:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100a8c:	39 c8                	cmp    %ecx,%eax
f0100a8e:	7e 0b                	jle    f0100a9b <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100a90:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100a94:	83 ea 0c             	sub    $0xc,%edx
f0100a97:	39 df                	cmp    %ebx,%edi
f0100a99:	75 ee                	jne    f0100a89 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100a9b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a9e:	89 06                	mov    %eax,(%esi)
	}
}
f0100aa0:	83 c4 14             	add    $0x14,%esp
f0100aa3:	5b                   	pop    %ebx
f0100aa4:	5e                   	pop    %esi
f0100aa5:	5f                   	pop    %edi
f0100aa6:	5d                   	pop    %ebp
f0100aa7:	c3                   	ret    

f0100aa8 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100aa8:	55                   	push   %ebp
f0100aa9:	89 e5                	mov    %esp,%ebp
f0100aab:	57                   	push   %edi
f0100aac:	56                   	push   %esi
f0100aad:	53                   	push   %ebx
f0100aae:	83 ec 3c             	sub    $0x3c,%esp
f0100ab1:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ab4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100ab7:	c7 03 50 1e 10 f0    	movl   $0xf0101e50,(%ebx)
	info->eip_line = 0;
f0100abd:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100ac4:	c7 43 08 50 1e 10 f0 	movl   $0xf0101e50,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100acb:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100ad2:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100ad5:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100adc:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100ae2:	76 11                	jbe    f0100af5 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100ae4:	b8 78 74 10 f0       	mov    $0xf0107478,%eax
f0100ae9:	3d 0d 5b 10 f0       	cmp    $0xf0105b0d,%eax
f0100aee:	77 19                	ja     f0100b09 <debuginfo_eip+0x61>
f0100af0:	e9 aa 01 00 00       	jmp    f0100c9f <debuginfo_eip+0x1f7>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100af5:	83 ec 04             	sub    $0x4,%esp
f0100af8:	68 5a 1e 10 f0       	push   $0xf0101e5a
f0100afd:	6a 7f                	push   $0x7f
f0100aff:	68 67 1e 10 f0       	push   $0xf0101e67
f0100b04:	e8 dd f5 ff ff       	call   f01000e6 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b09:	80 3d 77 74 10 f0 00 	cmpb   $0x0,0xf0107477
f0100b10:	0f 85 90 01 00 00    	jne    f0100ca6 <debuginfo_eip+0x1fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100b16:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b1d:	b8 0c 5b 10 f0       	mov    $0xf0105b0c,%eax
f0100b22:	2d b0 20 10 f0       	sub    $0xf01020b0,%eax
f0100b27:	c1 f8 02             	sar    $0x2,%eax
f0100b2a:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b30:	83 e8 01             	sub    $0x1,%eax
f0100b33:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b36:	83 ec 08             	sub    $0x8,%esp
f0100b39:	56                   	push   %esi
f0100b3a:	6a 64                	push   $0x64
f0100b3c:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b3f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b42:	b8 b0 20 10 f0       	mov    $0xf01020b0,%eax
f0100b47:	e8 66 fe ff ff       	call   f01009b2 <stab_binsearch>
	if (lfile == 0)
f0100b4c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b4f:	83 c4 10             	add    $0x10,%esp
f0100b52:	85 c0                	test   %eax,%eax
f0100b54:	0f 84 53 01 00 00    	je     f0100cad <debuginfo_eip+0x205>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b5a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b5d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b60:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b63:	83 ec 08             	sub    $0x8,%esp
f0100b66:	56                   	push   %esi
f0100b67:	6a 24                	push   $0x24
f0100b69:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b6c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b6f:	b8 b0 20 10 f0       	mov    $0xf01020b0,%eax
f0100b74:	e8 39 fe ff ff       	call   f01009b2 <stab_binsearch>

	if (lfun <= rfun) {
f0100b79:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100b7c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100b7f:	83 c4 10             	add    $0x10,%esp
f0100b82:	39 d0                	cmp    %edx,%eax
f0100b84:	7f 40                	jg     f0100bc6 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100b86:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100b89:	c1 e1 02             	shl    $0x2,%ecx
f0100b8c:	8d b9 b0 20 10 f0    	lea    -0xfefdf50(%ecx),%edi
f0100b92:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100b95:	8b b9 b0 20 10 f0    	mov    -0xfefdf50(%ecx),%edi
f0100b9b:	b9 78 74 10 f0       	mov    $0xf0107478,%ecx
f0100ba0:	81 e9 0d 5b 10 f0    	sub    $0xf0105b0d,%ecx
f0100ba6:	39 cf                	cmp    %ecx,%edi
f0100ba8:	73 09                	jae    f0100bb3 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100baa:	81 c7 0d 5b 10 f0    	add    $0xf0105b0d,%edi
f0100bb0:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100bb3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100bb6:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100bb9:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100bbc:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100bbe:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100bc1:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100bc4:	eb 0f                	jmp    f0100bd5 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100bc6:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100bc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bcc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100bcf:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bd2:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100bd5:	83 ec 08             	sub    $0x8,%esp
f0100bd8:	6a 3a                	push   $0x3a
f0100bda:	ff 73 08             	pushl  0x8(%ebx)
f0100bdd:	e8 59 08 00 00       	call   f010143b <strfind>
f0100be2:	2b 43 08             	sub    0x8(%ebx),%eax
f0100be5:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100be8:	83 c4 08             	add    $0x8,%esp
f0100beb:	56                   	push   %esi
f0100bec:	6a 44                	push   $0x44
f0100bee:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100bf1:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100bf4:	b8 b0 20 10 f0       	mov    $0xf01020b0,%eax
f0100bf9:	e8 b4 fd ff ff       	call   f01009b2 <stab_binsearch>
	if (lline > rline)
f0100bfe:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100c01:	83 c4 10             	add    $0x10,%esp
f0100c04:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100c07:	0f 8f a7 00 00 00    	jg     f0100cb4 <debuginfo_eip+0x20c>
		return -1;
	info->eip_line = stabs[lline].n_desc;
f0100c0d:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c10:	8d 04 85 b0 20 10 f0 	lea    -0xfefdf50(,%eax,4),%eax
f0100c17:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0100c1b:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c1e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100c21:	eb 06                	jmp    f0100c29 <debuginfo_eip+0x181>
f0100c23:	83 ea 01             	sub    $0x1,%edx
f0100c26:	83 e8 0c             	sub    $0xc,%eax
f0100c29:	39 d6                	cmp    %edx,%esi
f0100c2b:	7f 34                	jg     f0100c61 <debuginfo_eip+0x1b9>
	       && stabs[lline].n_type != N_SOL
f0100c2d:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100c31:	80 f9 84             	cmp    $0x84,%cl
f0100c34:	74 0b                	je     f0100c41 <debuginfo_eip+0x199>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c36:	80 f9 64             	cmp    $0x64,%cl
f0100c39:	75 e8                	jne    f0100c23 <debuginfo_eip+0x17b>
f0100c3b:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100c3f:	74 e2                	je     f0100c23 <debuginfo_eip+0x17b>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c41:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c44:	8b 14 85 b0 20 10 f0 	mov    -0xfefdf50(,%eax,4),%edx
f0100c4b:	b8 78 74 10 f0       	mov    $0xf0107478,%eax
f0100c50:	2d 0d 5b 10 f0       	sub    $0xf0105b0d,%eax
f0100c55:	39 c2                	cmp    %eax,%edx
f0100c57:	73 08                	jae    f0100c61 <debuginfo_eip+0x1b9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c59:	81 c2 0d 5b 10 f0    	add    $0xf0105b0d,%edx
f0100c5f:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c61:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c64:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c67:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c6c:	39 f2                	cmp    %esi,%edx
f0100c6e:	7d 50                	jge    f0100cc0 <debuginfo_eip+0x218>
		for (lline = lfun + 1;
f0100c70:	83 c2 01             	add    $0x1,%edx
f0100c73:	89 d0                	mov    %edx,%eax
f0100c75:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100c78:	8d 14 95 b0 20 10 f0 	lea    -0xfefdf50(,%edx,4),%edx
f0100c7f:	eb 04                	jmp    f0100c85 <debuginfo_eip+0x1dd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100c81:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100c85:	39 c6                	cmp    %eax,%esi
f0100c87:	7e 32                	jle    f0100cbb <debuginfo_eip+0x213>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100c89:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100c8d:	83 c0 01             	add    $0x1,%eax
f0100c90:	83 c2 0c             	add    $0xc,%edx
f0100c93:	80 f9 a0             	cmp    $0xa0,%cl
f0100c96:	74 e9                	je     f0100c81 <debuginfo_eip+0x1d9>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c98:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c9d:	eb 21                	jmp    f0100cc0 <debuginfo_eip+0x218>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100c9f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ca4:	eb 1a                	jmp    f0100cc0 <debuginfo_eip+0x218>
f0100ca6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cab:	eb 13                	jmp    f0100cc0 <debuginfo_eip+0x218>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100cad:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cb2:	eb 0c                	jmp    f0100cc0 <debuginfo_eip+0x218>
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline > rline)
		return -1;
f0100cb4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cb9:	eb 05                	jmp    f0100cc0 <debuginfo_eip+0x218>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cc3:	5b                   	pop    %ebx
f0100cc4:	5e                   	pop    %esi
f0100cc5:	5f                   	pop    %edi
f0100cc6:	5d                   	pop    %ebp
f0100cc7:	c3                   	ret    

f0100cc8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100cc8:	55                   	push   %ebp
f0100cc9:	89 e5                	mov    %esp,%ebp
f0100ccb:	57                   	push   %edi
f0100ccc:	56                   	push   %esi
f0100ccd:	53                   	push   %ebx
f0100cce:	83 ec 1c             	sub    $0x1c,%esp
f0100cd1:	89 c7                	mov    %eax,%edi
f0100cd3:	89 d6                	mov    %edx,%esi
f0100cd5:	8b 45 08             	mov    0x8(%ebp),%eax
f0100cd8:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100cdb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100cde:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100ce1:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100ce9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100cec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100cef:	39 d3                	cmp    %edx,%ebx
f0100cf1:	72 05                	jb     f0100cf8 <printnum+0x30>
f0100cf3:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100cf6:	77 45                	ja     f0100d3d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100cf8:	83 ec 0c             	sub    $0xc,%esp
f0100cfb:	ff 75 18             	pushl  0x18(%ebp)
f0100cfe:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d01:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100d04:	53                   	push   %ebx
f0100d05:	ff 75 10             	pushl  0x10(%ebp)
f0100d08:	83 ec 08             	sub    $0x8,%esp
f0100d0b:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d0e:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d11:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d14:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d17:	e8 44 09 00 00       	call   f0101660 <__udivdi3>
f0100d1c:	83 c4 18             	add    $0x18,%esp
f0100d1f:	52                   	push   %edx
f0100d20:	50                   	push   %eax
f0100d21:	89 f2                	mov    %esi,%edx
f0100d23:	89 f8                	mov    %edi,%eax
f0100d25:	e8 9e ff ff ff       	call   f0100cc8 <printnum>
f0100d2a:	83 c4 20             	add    $0x20,%esp
f0100d2d:	eb 18                	jmp    f0100d47 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d2f:	83 ec 08             	sub    $0x8,%esp
f0100d32:	56                   	push   %esi
f0100d33:	ff 75 18             	pushl  0x18(%ebp)
f0100d36:	ff d7                	call   *%edi
f0100d38:	83 c4 10             	add    $0x10,%esp
f0100d3b:	eb 03                	jmp    f0100d40 <printnum+0x78>
f0100d3d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d40:	83 eb 01             	sub    $0x1,%ebx
f0100d43:	85 db                	test   %ebx,%ebx
f0100d45:	7f e8                	jg     f0100d2f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d47:	83 ec 08             	sub    $0x8,%esp
f0100d4a:	56                   	push   %esi
f0100d4b:	83 ec 04             	sub    $0x4,%esp
f0100d4e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d51:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d54:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d57:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d5a:	e8 31 0a 00 00       	call   f0101790 <__umoddi3>
f0100d5f:	83 c4 14             	add    $0x14,%esp
f0100d62:	0f be 80 75 1e 10 f0 	movsbl -0xfefe18b(%eax),%eax
f0100d69:	50                   	push   %eax
f0100d6a:	ff d7                	call   *%edi
}
f0100d6c:	83 c4 10             	add    $0x10,%esp
f0100d6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d72:	5b                   	pop    %ebx
f0100d73:	5e                   	pop    %esi
f0100d74:	5f                   	pop    %edi
f0100d75:	5d                   	pop    %ebp
f0100d76:	c3                   	ret    

f0100d77 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100d77:	55                   	push   %ebp
f0100d78:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100d7a:	83 fa 01             	cmp    $0x1,%edx
f0100d7d:	7e 0e                	jle    f0100d8d <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100d7f:	8b 10                	mov    (%eax),%edx
f0100d81:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100d84:	89 08                	mov    %ecx,(%eax)
f0100d86:	8b 02                	mov    (%edx),%eax
f0100d88:	8b 52 04             	mov    0x4(%edx),%edx
f0100d8b:	eb 22                	jmp    f0100daf <getuint+0x38>
	else if (lflag)
f0100d8d:	85 d2                	test   %edx,%edx
f0100d8f:	74 10                	je     f0100da1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100d91:	8b 10                	mov    (%eax),%edx
f0100d93:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100d96:	89 08                	mov    %ecx,(%eax)
f0100d98:	8b 02                	mov    (%edx),%eax
f0100d9a:	ba 00 00 00 00       	mov    $0x0,%edx
f0100d9f:	eb 0e                	jmp    f0100daf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100da1:	8b 10                	mov    (%eax),%edx
f0100da3:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100da6:	89 08                	mov    %ecx,(%eax)
f0100da8:	8b 02                	mov    (%edx),%eax
f0100daa:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100daf:	5d                   	pop    %ebp
f0100db0:	c3                   	ret    

f0100db1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100db1:	55                   	push   %ebp
f0100db2:	89 e5                	mov    %esp,%ebp
f0100db4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100db7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100dbb:	8b 10                	mov    (%eax),%edx
f0100dbd:	3b 50 04             	cmp    0x4(%eax),%edx
f0100dc0:	73 0a                	jae    f0100dcc <sprintputch+0x1b>
		*b->buf++ = ch;
f0100dc2:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100dc5:	89 08                	mov    %ecx,(%eax)
f0100dc7:	8b 45 08             	mov    0x8(%ebp),%eax
f0100dca:	88 02                	mov    %al,(%edx)
}
f0100dcc:	5d                   	pop    %ebp
f0100dcd:	c3                   	ret    

f0100dce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100dce:	55                   	push   %ebp
f0100dcf:	89 e5                	mov    %esp,%ebp
f0100dd1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100dd4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100dd7:	50                   	push   %eax
f0100dd8:	ff 75 10             	pushl  0x10(%ebp)
f0100ddb:	ff 75 0c             	pushl  0xc(%ebp)
f0100dde:	ff 75 08             	pushl  0x8(%ebp)
f0100de1:	e8 05 00 00 00       	call   f0100deb <vprintfmt>
	va_end(ap);
}
f0100de6:	83 c4 10             	add    $0x10,%esp
f0100de9:	c9                   	leave  
f0100dea:	c3                   	ret    

f0100deb <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100deb:	55                   	push   %ebp
f0100dec:	89 e5                	mov    %esp,%ebp
f0100dee:	57                   	push   %edi
f0100def:	56                   	push   %esi
f0100df0:	53                   	push   %ebx
f0100df1:	83 ec 2c             	sub    $0x2c,%esp
f0100df4:	8b 75 08             	mov    0x8(%ebp),%esi
f0100df7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100dfa:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100dfd:	eb 12                	jmp    f0100e11 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100dff:	85 c0                	test   %eax,%eax
f0100e01:	0f 84 89 03 00 00    	je     f0101190 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0100e07:	83 ec 08             	sub    $0x8,%esp
f0100e0a:	53                   	push   %ebx
f0100e0b:	50                   	push   %eax
f0100e0c:	ff d6                	call   *%esi
f0100e0e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100e11:	83 c7 01             	add    $0x1,%edi
f0100e14:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100e18:	83 f8 25             	cmp    $0x25,%eax
f0100e1b:	75 e2                	jne    f0100dff <vprintfmt+0x14>
f0100e1d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100e21:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100e28:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100e2f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100e36:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e3b:	eb 07                	jmp    f0100e44 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100e40:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e44:	8d 47 01             	lea    0x1(%edi),%eax
f0100e47:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e4a:	0f b6 07             	movzbl (%edi),%eax
f0100e4d:	0f b6 c8             	movzbl %al,%ecx
f0100e50:	83 e8 23             	sub    $0x23,%eax
f0100e53:	3c 55                	cmp    $0x55,%al
f0100e55:	0f 87 1a 03 00 00    	ja     f0101175 <vprintfmt+0x38a>
f0100e5b:	0f b6 c0             	movzbl %al,%eax
f0100e5e:	ff 24 85 20 1f 10 f0 	jmp    *-0xfefe0e0(,%eax,4)
f0100e65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100e68:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100e6c:	eb d6                	jmp    f0100e44 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e6e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e71:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e76:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100e79:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100e7c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0100e80:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0100e83:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0100e86:	83 fa 09             	cmp    $0x9,%edx
f0100e89:	77 39                	ja     f0100ec4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100e8b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100e8e:	eb e9                	jmp    f0100e79 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100e90:	8b 45 14             	mov    0x14(%ebp),%eax
f0100e93:	8d 48 04             	lea    0x4(%eax),%ecx
f0100e96:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100e99:	8b 00                	mov    (%eax),%eax
f0100e9b:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100ea1:	eb 27                	jmp    f0100eca <vprintfmt+0xdf>
f0100ea3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ea6:	85 c0                	test   %eax,%eax
f0100ea8:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ead:	0f 49 c8             	cmovns %eax,%ecx
f0100eb0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100eb3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100eb6:	eb 8c                	jmp    f0100e44 <vprintfmt+0x59>
f0100eb8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100ebb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100ec2:	eb 80                	jmp    f0100e44 <vprintfmt+0x59>
f0100ec4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ec7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100eca:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100ece:	0f 89 70 ff ff ff    	jns    f0100e44 <vprintfmt+0x59>
				width = precision, precision = -1;
f0100ed4:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100ed7:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100eda:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100ee1:	e9 5e ff ff ff       	jmp    f0100e44 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100ee6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ee9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100eec:	e9 53 ff ff ff       	jmp    f0100e44 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100ef1:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ef4:	8d 50 04             	lea    0x4(%eax),%edx
f0100ef7:	89 55 14             	mov    %edx,0x14(%ebp)
f0100efa:	83 ec 08             	sub    $0x8,%esp
f0100efd:	53                   	push   %ebx
f0100efe:	ff 30                	pushl  (%eax)
f0100f00:	ff d6                	call   *%esi
			break;
f0100f02:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f05:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100f08:	e9 04 ff ff ff       	jmp    f0100e11 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100f0d:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f10:	8d 50 04             	lea    0x4(%eax),%edx
f0100f13:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f16:	8b 00                	mov    (%eax),%eax
f0100f18:	99                   	cltd   
f0100f19:	31 d0                	xor    %edx,%eax
f0100f1b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f1d:	83 f8 07             	cmp    $0x7,%eax
f0100f20:	7f 0b                	jg     f0100f2d <vprintfmt+0x142>
f0100f22:	8b 14 85 80 20 10 f0 	mov    -0xfefdf80(,%eax,4),%edx
f0100f29:	85 d2                	test   %edx,%edx
f0100f2b:	75 18                	jne    f0100f45 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0100f2d:	50                   	push   %eax
f0100f2e:	68 8d 1e 10 f0       	push   $0xf0101e8d
f0100f33:	53                   	push   %ebx
f0100f34:	56                   	push   %esi
f0100f35:	e8 94 fe ff ff       	call   f0100dce <printfmt>
f0100f3a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f3d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100f40:	e9 cc fe ff ff       	jmp    f0100e11 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100f45:	52                   	push   %edx
f0100f46:	68 96 1e 10 f0       	push   $0xf0101e96
f0100f4b:	53                   	push   %ebx
f0100f4c:	56                   	push   %esi
f0100f4d:	e8 7c fe ff ff       	call   f0100dce <printfmt>
f0100f52:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f55:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f58:	e9 b4 fe ff ff       	jmp    f0100e11 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f5d:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f60:	8d 50 04             	lea    0x4(%eax),%edx
f0100f63:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f66:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100f68:	85 ff                	test   %edi,%edi
f0100f6a:	b8 86 1e 10 f0       	mov    $0xf0101e86,%eax
f0100f6f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100f72:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f76:	0f 8e 94 00 00 00    	jle    f0101010 <vprintfmt+0x225>
f0100f7c:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100f80:	0f 84 98 00 00 00    	je     f010101e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100f86:	83 ec 08             	sub    $0x8,%esp
f0100f89:	ff 75 d0             	pushl  -0x30(%ebp)
f0100f8c:	57                   	push   %edi
f0100f8d:	e8 5f 03 00 00       	call   f01012f1 <strnlen>
f0100f92:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100f95:	29 c1                	sub    %eax,%ecx
f0100f97:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100f9a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100f9d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100fa1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100fa4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100fa7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fa9:	eb 0f                	jmp    f0100fba <vprintfmt+0x1cf>
					putch(padc, putdat);
f0100fab:	83 ec 08             	sub    $0x8,%esp
f0100fae:	53                   	push   %ebx
f0100faf:	ff 75 e0             	pushl  -0x20(%ebp)
f0100fb2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fb4:	83 ef 01             	sub    $0x1,%edi
f0100fb7:	83 c4 10             	add    $0x10,%esp
f0100fba:	85 ff                	test   %edi,%edi
f0100fbc:	7f ed                	jg     f0100fab <vprintfmt+0x1c0>
f0100fbe:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100fc1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100fc4:	85 c9                	test   %ecx,%ecx
f0100fc6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fcb:	0f 49 c1             	cmovns %ecx,%eax
f0100fce:	29 c1                	sub    %eax,%ecx
f0100fd0:	89 75 08             	mov    %esi,0x8(%ebp)
f0100fd3:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0100fd6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0100fd9:	89 cb                	mov    %ecx,%ebx
f0100fdb:	eb 4d                	jmp    f010102a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0100fdd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0100fe1:	74 1b                	je     f0100ffe <vprintfmt+0x213>
f0100fe3:	0f be c0             	movsbl %al,%eax
f0100fe6:	83 e8 20             	sub    $0x20,%eax
f0100fe9:	83 f8 5e             	cmp    $0x5e,%eax
f0100fec:	76 10                	jbe    f0100ffe <vprintfmt+0x213>
					putch('?', putdat);
f0100fee:	83 ec 08             	sub    $0x8,%esp
f0100ff1:	ff 75 0c             	pushl  0xc(%ebp)
f0100ff4:	6a 3f                	push   $0x3f
f0100ff6:	ff 55 08             	call   *0x8(%ebp)
f0100ff9:	83 c4 10             	add    $0x10,%esp
f0100ffc:	eb 0d                	jmp    f010100b <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0100ffe:	83 ec 08             	sub    $0x8,%esp
f0101001:	ff 75 0c             	pushl  0xc(%ebp)
f0101004:	52                   	push   %edx
f0101005:	ff 55 08             	call   *0x8(%ebp)
f0101008:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010100b:	83 eb 01             	sub    $0x1,%ebx
f010100e:	eb 1a                	jmp    f010102a <vprintfmt+0x23f>
f0101010:	89 75 08             	mov    %esi,0x8(%ebp)
f0101013:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101016:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101019:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010101c:	eb 0c                	jmp    f010102a <vprintfmt+0x23f>
f010101e:	89 75 08             	mov    %esi,0x8(%ebp)
f0101021:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101024:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101027:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010102a:	83 c7 01             	add    $0x1,%edi
f010102d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101031:	0f be d0             	movsbl %al,%edx
f0101034:	85 d2                	test   %edx,%edx
f0101036:	74 23                	je     f010105b <vprintfmt+0x270>
f0101038:	85 f6                	test   %esi,%esi
f010103a:	78 a1                	js     f0100fdd <vprintfmt+0x1f2>
f010103c:	83 ee 01             	sub    $0x1,%esi
f010103f:	79 9c                	jns    f0100fdd <vprintfmt+0x1f2>
f0101041:	89 df                	mov    %ebx,%edi
f0101043:	8b 75 08             	mov    0x8(%ebp),%esi
f0101046:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101049:	eb 18                	jmp    f0101063 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010104b:	83 ec 08             	sub    $0x8,%esp
f010104e:	53                   	push   %ebx
f010104f:	6a 20                	push   $0x20
f0101051:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101053:	83 ef 01             	sub    $0x1,%edi
f0101056:	83 c4 10             	add    $0x10,%esp
f0101059:	eb 08                	jmp    f0101063 <vprintfmt+0x278>
f010105b:	89 df                	mov    %ebx,%edi
f010105d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101060:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101063:	85 ff                	test   %edi,%edi
f0101065:	7f e4                	jg     f010104b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101067:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010106a:	e9 a2 fd ff ff       	jmp    f0100e11 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010106f:	83 fa 01             	cmp    $0x1,%edx
f0101072:	7e 16                	jle    f010108a <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0101074:	8b 45 14             	mov    0x14(%ebp),%eax
f0101077:	8d 50 08             	lea    0x8(%eax),%edx
f010107a:	89 55 14             	mov    %edx,0x14(%ebp)
f010107d:	8b 50 04             	mov    0x4(%eax),%edx
f0101080:	8b 00                	mov    (%eax),%eax
f0101082:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101085:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101088:	eb 32                	jmp    f01010bc <vprintfmt+0x2d1>
	else if (lflag)
f010108a:	85 d2                	test   %edx,%edx
f010108c:	74 18                	je     f01010a6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f010108e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101091:	8d 50 04             	lea    0x4(%eax),%edx
f0101094:	89 55 14             	mov    %edx,0x14(%ebp)
f0101097:	8b 00                	mov    (%eax),%eax
f0101099:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010109c:	89 c1                	mov    %eax,%ecx
f010109e:	c1 f9 1f             	sar    $0x1f,%ecx
f01010a1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01010a4:	eb 16                	jmp    f01010bc <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f01010a6:	8b 45 14             	mov    0x14(%ebp),%eax
f01010a9:	8d 50 04             	lea    0x4(%eax),%edx
f01010ac:	89 55 14             	mov    %edx,0x14(%ebp)
f01010af:	8b 00                	mov    (%eax),%eax
f01010b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010b4:	89 c1                	mov    %eax,%ecx
f01010b6:	c1 f9 1f             	sar    $0x1f,%ecx
f01010b9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01010bc:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010bf:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01010c2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01010c7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01010cb:	79 74                	jns    f0101141 <vprintfmt+0x356>
				putch('-', putdat);
f01010cd:	83 ec 08             	sub    $0x8,%esp
f01010d0:	53                   	push   %ebx
f01010d1:	6a 2d                	push   $0x2d
f01010d3:	ff d6                	call   *%esi
				num = -(long long) num;
f01010d5:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010d8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01010db:	f7 d8                	neg    %eax
f01010dd:	83 d2 00             	adc    $0x0,%edx
f01010e0:	f7 da                	neg    %edx
f01010e2:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f01010e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
f01010ea:	eb 55                	jmp    f0101141 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f01010ec:	8d 45 14             	lea    0x14(%ebp),%eax
f01010ef:	e8 83 fc ff ff       	call   f0100d77 <getuint>
			base = 10;
f01010f4:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f01010f9:	eb 46                	jmp    f0101141 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f01010fb:	8d 45 14             	lea    0x14(%ebp),%eax
f01010fe:	e8 74 fc ff ff       	call   f0100d77 <getuint>
			base = 8;
f0101103:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0101108:	eb 37                	jmp    f0101141 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f010110a:	83 ec 08             	sub    $0x8,%esp
f010110d:	53                   	push   %ebx
f010110e:	6a 30                	push   $0x30
f0101110:	ff d6                	call   *%esi
			putch('x', putdat);
f0101112:	83 c4 08             	add    $0x8,%esp
f0101115:	53                   	push   %ebx
f0101116:	6a 78                	push   $0x78
f0101118:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010111a:	8b 45 14             	mov    0x14(%ebp),%eax
f010111d:	8d 50 04             	lea    0x4(%eax),%edx
f0101120:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101123:	8b 00                	mov    (%eax),%eax
f0101125:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010112a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010112d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0101132:	eb 0d                	jmp    f0101141 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101134:	8d 45 14             	lea    0x14(%ebp),%eax
f0101137:	e8 3b fc ff ff       	call   f0100d77 <getuint>
			base = 16;
f010113c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101141:	83 ec 0c             	sub    $0xc,%esp
f0101144:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101148:	57                   	push   %edi
f0101149:	ff 75 e0             	pushl  -0x20(%ebp)
f010114c:	51                   	push   %ecx
f010114d:	52                   	push   %edx
f010114e:	50                   	push   %eax
f010114f:	89 da                	mov    %ebx,%edx
f0101151:	89 f0                	mov    %esi,%eax
f0101153:	e8 70 fb ff ff       	call   f0100cc8 <printnum>
			break;
f0101158:	83 c4 20             	add    $0x20,%esp
f010115b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010115e:	e9 ae fc ff ff       	jmp    f0100e11 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101163:	83 ec 08             	sub    $0x8,%esp
f0101166:	53                   	push   %ebx
f0101167:	51                   	push   %ecx
f0101168:	ff d6                	call   *%esi
			break;
f010116a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010116d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101170:	e9 9c fc ff ff       	jmp    f0100e11 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101175:	83 ec 08             	sub    $0x8,%esp
f0101178:	53                   	push   %ebx
f0101179:	6a 25                	push   $0x25
f010117b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010117d:	83 c4 10             	add    $0x10,%esp
f0101180:	eb 03                	jmp    f0101185 <vprintfmt+0x39a>
f0101182:	83 ef 01             	sub    $0x1,%edi
f0101185:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0101189:	75 f7                	jne    f0101182 <vprintfmt+0x397>
f010118b:	e9 81 fc ff ff       	jmp    f0100e11 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0101190:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101193:	5b                   	pop    %ebx
f0101194:	5e                   	pop    %esi
f0101195:	5f                   	pop    %edi
f0101196:	5d                   	pop    %ebp
f0101197:	c3                   	ret    

f0101198 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101198:	55                   	push   %ebp
f0101199:	89 e5                	mov    %esp,%ebp
f010119b:	83 ec 18             	sub    $0x18,%esp
f010119e:	8b 45 08             	mov    0x8(%ebp),%eax
f01011a1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01011a4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01011a7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01011ab:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01011ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01011b5:	85 c0                	test   %eax,%eax
f01011b7:	74 26                	je     f01011df <vsnprintf+0x47>
f01011b9:	85 d2                	test   %edx,%edx
f01011bb:	7e 22                	jle    f01011df <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01011bd:	ff 75 14             	pushl  0x14(%ebp)
f01011c0:	ff 75 10             	pushl  0x10(%ebp)
f01011c3:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01011c6:	50                   	push   %eax
f01011c7:	68 b1 0d 10 f0       	push   $0xf0100db1
f01011cc:	e8 1a fc ff ff       	call   f0100deb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01011d1:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01011d4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01011d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01011da:	83 c4 10             	add    $0x10,%esp
f01011dd:	eb 05                	jmp    f01011e4 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01011df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01011e4:	c9                   	leave  
f01011e5:	c3                   	ret    

f01011e6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01011e6:	55                   	push   %ebp
f01011e7:	89 e5                	mov    %esp,%ebp
f01011e9:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01011ec:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f01011ef:	50                   	push   %eax
f01011f0:	ff 75 10             	pushl  0x10(%ebp)
f01011f3:	ff 75 0c             	pushl  0xc(%ebp)
f01011f6:	ff 75 08             	pushl  0x8(%ebp)
f01011f9:	e8 9a ff ff ff       	call   f0101198 <vsnprintf>
	va_end(ap);

	return rc;
}
f01011fe:	c9                   	leave  
f01011ff:	c3                   	ret    

f0101200 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101200:	55                   	push   %ebp
f0101201:	89 e5                	mov    %esp,%ebp
f0101203:	57                   	push   %edi
f0101204:	56                   	push   %esi
f0101205:	53                   	push   %ebx
f0101206:	83 ec 0c             	sub    $0xc,%esp
f0101209:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f010120c:	85 c0                	test   %eax,%eax
f010120e:	74 11                	je     f0101221 <readline+0x21>
		cprintf("%s", prompt);
f0101210:	83 ec 08             	sub    $0x8,%esp
f0101213:	50                   	push   %eax
f0101214:	68 96 1e 10 f0       	push   $0xf0101e96
f0101219:	e8 80 f7 ff ff       	call   f010099e <cprintf>
f010121e:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101221:	83 ec 0c             	sub    $0xc,%esp
f0101224:	6a 00                	push   $0x0
f0101226:	e8 43 f4 ff ff       	call   f010066e <iscons>
f010122b:	89 c7                	mov    %eax,%edi
f010122d:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0101230:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101235:	e8 23 f4 ff ff       	call   f010065d <getchar>
f010123a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010123c:	85 c0                	test   %eax,%eax
f010123e:	79 18                	jns    f0101258 <readline+0x58>
			cprintf("read error: %e\n", c);
f0101240:	83 ec 08             	sub    $0x8,%esp
f0101243:	50                   	push   %eax
f0101244:	68 a0 20 10 f0       	push   $0xf01020a0
f0101249:	e8 50 f7 ff ff       	call   f010099e <cprintf>
			return NULL;
f010124e:	83 c4 10             	add    $0x10,%esp
f0101251:	b8 00 00 00 00       	mov    $0x0,%eax
f0101256:	eb 79                	jmp    f01012d1 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101258:	83 f8 08             	cmp    $0x8,%eax
f010125b:	0f 94 c2             	sete   %dl
f010125e:	83 f8 7f             	cmp    $0x7f,%eax
f0101261:	0f 94 c0             	sete   %al
f0101264:	08 c2                	or     %al,%dl
f0101266:	74 1a                	je     f0101282 <readline+0x82>
f0101268:	85 f6                	test   %esi,%esi
f010126a:	7e 16                	jle    f0101282 <readline+0x82>
			if (echoing)
f010126c:	85 ff                	test   %edi,%edi
f010126e:	74 0d                	je     f010127d <readline+0x7d>
				cputchar('\b');
f0101270:	83 ec 0c             	sub    $0xc,%esp
f0101273:	6a 08                	push   $0x8
f0101275:	e8 d3 f3 ff ff       	call   f010064d <cputchar>
f010127a:	83 c4 10             	add    $0x10,%esp
			i--;
f010127d:	83 ee 01             	sub    $0x1,%esi
f0101280:	eb b3                	jmp    f0101235 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101282:	83 fb 1f             	cmp    $0x1f,%ebx
f0101285:	7e 23                	jle    f01012aa <readline+0xaa>
f0101287:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f010128d:	7f 1b                	jg     f01012aa <readline+0xaa>
			if (echoing)
f010128f:	85 ff                	test   %edi,%edi
f0101291:	74 0c                	je     f010129f <readline+0x9f>
				cputchar(c);
f0101293:	83 ec 0c             	sub    $0xc,%esp
f0101296:	53                   	push   %ebx
f0101297:	e8 b1 f3 ff ff       	call   f010064d <cputchar>
f010129c:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f010129f:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f01012a5:	8d 76 01             	lea    0x1(%esi),%esi
f01012a8:	eb 8b                	jmp    f0101235 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01012aa:	83 fb 0a             	cmp    $0xa,%ebx
f01012ad:	74 05                	je     f01012b4 <readline+0xb4>
f01012af:	83 fb 0d             	cmp    $0xd,%ebx
f01012b2:	75 81                	jne    f0101235 <readline+0x35>
			if (echoing)
f01012b4:	85 ff                	test   %edi,%edi
f01012b6:	74 0d                	je     f01012c5 <readline+0xc5>
				cputchar('\n');
f01012b8:	83 ec 0c             	sub    $0xc,%esp
f01012bb:	6a 0a                	push   $0xa
f01012bd:	e8 8b f3 ff ff       	call   f010064d <cputchar>
f01012c2:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01012c5:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f01012cc:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f01012d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01012d4:	5b                   	pop    %ebx
f01012d5:	5e                   	pop    %esi
f01012d6:	5f                   	pop    %edi
f01012d7:	5d                   	pop    %ebp
f01012d8:	c3                   	ret    

f01012d9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01012d9:	55                   	push   %ebp
f01012da:	89 e5                	mov    %esp,%ebp
f01012dc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01012df:	b8 00 00 00 00       	mov    $0x0,%eax
f01012e4:	eb 03                	jmp    f01012e9 <strlen+0x10>
		n++;
f01012e6:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01012e9:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01012ed:	75 f7                	jne    f01012e6 <strlen+0xd>
		n++;
	return n;
}
f01012ef:	5d                   	pop    %ebp
f01012f0:	c3                   	ret    

f01012f1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01012f1:	55                   	push   %ebp
f01012f2:	89 e5                	mov    %esp,%ebp
f01012f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01012f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01012fa:	ba 00 00 00 00       	mov    $0x0,%edx
f01012ff:	eb 03                	jmp    f0101304 <strnlen+0x13>
		n++;
f0101301:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101304:	39 c2                	cmp    %eax,%edx
f0101306:	74 08                	je     f0101310 <strnlen+0x1f>
f0101308:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010130c:	75 f3                	jne    f0101301 <strnlen+0x10>
f010130e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0101310:	5d                   	pop    %ebp
f0101311:	c3                   	ret    

f0101312 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101312:	55                   	push   %ebp
f0101313:	89 e5                	mov    %esp,%ebp
f0101315:	53                   	push   %ebx
f0101316:	8b 45 08             	mov    0x8(%ebp),%eax
f0101319:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010131c:	89 c2                	mov    %eax,%edx
f010131e:	83 c2 01             	add    $0x1,%edx
f0101321:	83 c1 01             	add    $0x1,%ecx
f0101324:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101328:	88 5a ff             	mov    %bl,-0x1(%edx)
f010132b:	84 db                	test   %bl,%bl
f010132d:	75 ef                	jne    f010131e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010132f:	5b                   	pop    %ebx
f0101330:	5d                   	pop    %ebp
f0101331:	c3                   	ret    

f0101332 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101332:	55                   	push   %ebp
f0101333:	89 e5                	mov    %esp,%ebp
f0101335:	53                   	push   %ebx
f0101336:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101339:	53                   	push   %ebx
f010133a:	e8 9a ff ff ff       	call   f01012d9 <strlen>
f010133f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101342:	ff 75 0c             	pushl  0xc(%ebp)
f0101345:	01 d8                	add    %ebx,%eax
f0101347:	50                   	push   %eax
f0101348:	e8 c5 ff ff ff       	call   f0101312 <strcpy>
	return dst;
}
f010134d:	89 d8                	mov    %ebx,%eax
f010134f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101352:	c9                   	leave  
f0101353:	c3                   	ret    

f0101354 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101354:	55                   	push   %ebp
f0101355:	89 e5                	mov    %esp,%ebp
f0101357:	56                   	push   %esi
f0101358:	53                   	push   %ebx
f0101359:	8b 75 08             	mov    0x8(%ebp),%esi
f010135c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010135f:	89 f3                	mov    %esi,%ebx
f0101361:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101364:	89 f2                	mov    %esi,%edx
f0101366:	eb 0f                	jmp    f0101377 <strncpy+0x23>
		*dst++ = *src;
f0101368:	83 c2 01             	add    $0x1,%edx
f010136b:	0f b6 01             	movzbl (%ecx),%eax
f010136e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101371:	80 39 01             	cmpb   $0x1,(%ecx)
f0101374:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101377:	39 da                	cmp    %ebx,%edx
f0101379:	75 ed                	jne    f0101368 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f010137b:	89 f0                	mov    %esi,%eax
f010137d:	5b                   	pop    %ebx
f010137e:	5e                   	pop    %esi
f010137f:	5d                   	pop    %ebp
f0101380:	c3                   	ret    

f0101381 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101381:	55                   	push   %ebp
f0101382:	89 e5                	mov    %esp,%ebp
f0101384:	56                   	push   %esi
f0101385:	53                   	push   %ebx
f0101386:	8b 75 08             	mov    0x8(%ebp),%esi
f0101389:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010138c:	8b 55 10             	mov    0x10(%ebp),%edx
f010138f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101391:	85 d2                	test   %edx,%edx
f0101393:	74 21                	je     f01013b6 <strlcpy+0x35>
f0101395:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101399:	89 f2                	mov    %esi,%edx
f010139b:	eb 09                	jmp    f01013a6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010139d:	83 c2 01             	add    $0x1,%edx
f01013a0:	83 c1 01             	add    $0x1,%ecx
f01013a3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01013a6:	39 c2                	cmp    %eax,%edx
f01013a8:	74 09                	je     f01013b3 <strlcpy+0x32>
f01013aa:	0f b6 19             	movzbl (%ecx),%ebx
f01013ad:	84 db                	test   %bl,%bl
f01013af:	75 ec                	jne    f010139d <strlcpy+0x1c>
f01013b1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01013b3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01013b6:	29 f0                	sub    %esi,%eax
}
f01013b8:	5b                   	pop    %ebx
f01013b9:	5e                   	pop    %esi
f01013ba:	5d                   	pop    %ebp
f01013bb:	c3                   	ret    

f01013bc <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01013bc:	55                   	push   %ebp
f01013bd:	89 e5                	mov    %esp,%ebp
f01013bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01013c2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01013c5:	eb 06                	jmp    f01013cd <strcmp+0x11>
		p++, q++;
f01013c7:	83 c1 01             	add    $0x1,%ecx
f01013ca:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01013cd:	0f b6 01             	movzbl (%ecx),%eax
f01013d0:	84 c0                	test   %al,%al
f01013d2:	74 04                	je     f01013d8 <strcmp+0x1c>
f01013d4:	3a 02                	cmp    (%edx),%al
f01013d6:	74 ef                	je     f01013c7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01013d8:	0f b6 c0             	movzbl %al,%eax
f01013db:	0f b6 12             	movzbl (%edx),%edx
f01013de:	29 d0                	sub    %edx,%eax
}
f01013e0:	5d                   	pop    %ebp
f01013e1:	c3                   	ret    

f01013e2 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01013e2:	55                   	push   %ebp
f01013e3:	89 e5                	mov    %esp,%ebp
f01013e5:	53                   	push   %ebx
f01013e6:	8b 45 08             	mov    0x8(%ebp),%eax
f01013e9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01013ec:	89 c3                	mov    %eax,%ebx
f01013ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01013f1:	eb 06                	jmp    f01013f9 <strncmp+0x17>
		n--, p++, q++;
f01013f3:	83 c0 01             	add    $0x1,%eax
f01013f6:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01013f9:	39 d8                	cmp    %ebx,%eax
f01013fb:	74 15                	je     f0101412 <strncmp+0x30>
f01013fd:	0f b6 08             	movzbl (%eax),%ecx
f0101400:	84 c9                	test   %cl,%cl
f0101402:	74 04                	je     f0101408 <strncmp+0x26>
f0101404:	3a 0a                	cmp    (%edx),%cl
f0101406:	74 eb                	je     f01013f3 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101408:	0f b6 00             	movzbl (%eax),%eax
f010140b:	0f b6 12             	movzbl (%edx),%edx
f010140e:	29 d0                	sub    %edx,%eax
f0101410:	eb 05                	jmp    f0101417 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0101412:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101417:	5b                   	pop    %ebx
f0101418:	5d                   	pop    %ebp
f0101419:	c3                   	ret    

f010141a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010141a:	55                   	push   %ebp
f010141b:	89 e5                	mov    %esp,%ebp
f010141d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101420:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101424:	eb 07                	jmp    f010142d <strchr+0x13>
		if (*s == c)
f0101426:	38 ca                	cmp    %cl,%dl
f0101428:	74 0f                	je     f0101439 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010142a:	83 c0 01             	add    $0x1,%eax
f010142d:	0f b6 10             	movzbl (%eax),%edx
f0101430:	84 d2                	test   %dl,%dl
f0101432:	75 f2                	jne    f0101426 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101434:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101439:	5d                   	pop    %ebp
f010143a:	c3                   	ret    

f010143b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010143b:	55                   	push   %ebp
f010143c:	89 e5                	mov    %esp,%ebp
f010143e:	8b 45 08             	mov    0x8(%ebp),%eax
f0101441:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101445:	eb 03                	jmp    f010144a <strfind+0xf>
f0101447:	83 c0 01             	add    $0x1,%eax
f010144a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010144d:	38 ca                	cmp    %cl,%dl
f010144f:	74 04                	je     f0101455 <strfind+0x1a>
f0101451:	84 d2                	test   %dl,%dl
f0101453:	75 f2                	jne    f0101447 <strfind+0xc>
			break;
	return (char *) s;
}
f0101455:	5d                   	pop    %ebp
f0101456:	c3                   	ret    

f0101457 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101457:	55                   	push   %ebp
f0101458:	89 e5                	mov    %esp,%ebp
f010145a:	57                   	push   %edi
f010145b:	56                   	push   %esi
f010145c:	53                   	push   %ebx
f010145d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0101460:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101463:	85 c9                	test   %ecx,%ecx
f0101465:	74 36                	je     f010149d <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101467:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010146d:	75 28                	jne    f0101497 <memset+0x40>
f010146f:	f6 c1 03             	test   $0x3,%cl
f0101472:	75 23                	jne    f0101497 <memset+0x40>
		c &= 0xFF;
f0101474:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0101478:	89 d3                	mov    %edx,%ebx
f010147a:	c1 e3 08             	shl    $0x8,%ebx
f010147d:	89 d6                	mov    %edx,%esi
f010147f:	c1 e6 18             	shl    $0x18,%esi
f0101482:	89 d0                	mov    %edx,%eax
f0101484:	c1 e0 10             	shl    $0x10,%eax
f0101487:	09 f0                	or     %esi,%eax
f0101489:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f010148b:	89 d8                	mov    %ebx,%eax
f010148d:	09 d0                	or     %edx,%eax
f010148f:	c1 e9 02             	shr    $0x2,%ecx
f0101492:	fc                   	cld    
f0101493:	f3 ab                	rep stos %eax,%es:(%edi)
f0101495:	eb 06                	jmp    f010149d <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0101497:	8b 45 0c             	mov    0xc(%ebp),%eax
f010149a:	fc                   	cld    
f010149b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010149d:	89 f8                	mov    %edi,%eax
f010149f:	5b                   	pop    %ebx
f01014a0:	5e                   	pop    %esi
f01014a1:	5f                   	pop    %edi
f01014a2:	5d                   	pop    %ebp
f01014a3:	c3                   	ret    

f01014a4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01014a4:	55                   	push   %ebp
f01014a5:	89 e5                	mov    %esp,%ebp
f01014a7:	57                   	push   %edi
f01014a8:	56                   	push   %esi
f01014a9:	8b 45 08             	mov    0x8(%ebp),%eax
f01014ac:	8b 75 0c             	mov    0xc(%ebp),%esi
f01014af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01014b2:	39 c6                	cmp    %eax,%esi
f01014b4:	73 35                	jae    f01014eb <memmove+0x47>
f01014b6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01014b9:	39 d0                	cmp    %edx,%eax
f01014bb:	73 2e                	jae    f01014eb <memmove+0x47>
		s += n;
		d += n;
f01014bd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014c0:	89 d6                	mov    %edx,%esi
f01014c2:	09 fe                	or     %edi,%esi
f01014c4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01014ca:	75 13                	jne    f01014df <memmove+0x3b>
f01014cc:	f6 c1 03             	test   $0x3,%cl
f01014cf:	75 0e                	jne    f01014df <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01014d1:	83 ef 04             	sub    $0x4,%edi
f01014d4:	8d 72 fc             	lea    -0x4(%edx),%esi
f01014d7:	c1 e9 02             	shr    $0x2,%ecx
f01014da:	fd                   	std    
f01014db:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01014dd:	eb 09                	jmp    f01014e8 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01014df:	83 ef 01             	sub    $0x1,%edi
f01014e2:	8d 72 ff             	lea    -0x1(%edx),%esi
f01014e5:	fd                   	std    
f01014e6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01014e8:	fc                   	cld    
f01014e9:	eb 1d                	jmp    f0101508 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014eb:	89 f2                	mov    %esi,%edx
f01014ed:	09 c2                	or     %eax,%edx
f01014ef:	f6 c2 03             	test   $0x3,%dl
f01014f2:	75 0f                	jne    f0101503 <memmove+0x5f>
f01014f4:	f6 c1 03             	test   $0x3,%cl
f01014f7:	75 0a                	jne    f0101503 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01014f9:	c1 e9 02             	shr    $0x2,%ecx
f01014fc:	89 c7                	mov    %eax,%edi
f01014fe:	fc                   	cld    
f01014ff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101501:	eb 05                	jmp    f0101508 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101503:	89 c7                	mov    %eax,%edi
f0101505:	fc                   	cld    
f0101506:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101508:	5e                   	pop    %esi
f0101509:	5f                   	pop    %edi
f010150a:	5d                   	pop    %ebp
f010150b:	c3                   	ret    

f010150c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010150c:	55                   	push   %ebp
f010150d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010150f:	ff 75 10             	pushl  0x10(%ebp)
f0101512:	ff 75 0c             	pushl  0xc(%ebp)
f0101515:	ff 75 08             	pushl  0x8(%ebp)
f0101518:	e8 87 ff ff ff       	call   f01014a4 <memmove>
}
f010151d:	c9                   	leave  
f010151e:	c3                   	ret    

f010151f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010151f:	55                   	push   %ebp
f0101520:	89 e5                	mov    %esp,%ebp
f0101522:	56                   	push   %esi
f0101523:	53                   	push   %ebx
f0101524:	8b 45 08             	mov    0x8(%ebp),%eax
f0101527:	8b 55 0c             	mov    0xc(%ebp),%edx
f010152a:	89 c6                	mov    %eax,%esi
f010152c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010152f:	eb 1a                	jmp    f010154b <memcmp+0x2c>
		if (*s1 != *s2)
f0101531:	0f b6 08             	movzbl (%eax),%ecx
f0101534:	0f b6 1a             	movzbl (%edx),%ebx
f0101537:	38 d9                	cmp    %bl,%cl
f0101539:	74 0a                	je     f0101545 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010153b:	0f b6 c1             	movzbl %cl,%eax
f010153e:	0f b6 db             	movzbl %bl,%ebx
f0101541:	29 d8                	sub    %ebx,%eax
f0101543:	eb 0f                	jmp    f0101554 <memcmp+0x35>
		s1++, s2++;
f0101545:	83 c0 01             	add    $0x1,%eax
f0101548:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010154b:	39 f0                	cmp    %esi,%eax
f010154d:	75 e2                	jne    f0101531 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010154f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101554:	5b                   	pop    %ebx
f0101555:	5e                   	pop    %esi
f0101556:	5d                   	pop    %ebp
f0101557:	c3                   	ret    

f0101558 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101558:	55                   	push   %ebp
f0101559:	89 e5                	mov    %esp,%ebp
f010155b:	53                   	push   %ebx
f010155c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010155f:	89 c1                	mov    %eax,%ecx
f0101561:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0101564:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101568:	eb 0a                	jmp    f0101574 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010156a:	0f b6 10             	movzbl (%eax),%edx
f010156d:	39 da                	cmp    %ebx,%edx
f010156f:	74 07                	je     f0101578 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101571:	83 c0 01             	add    $0x1,%eax
f0101574:	39 c8                	cmp    %ecx,%eax
f0101576:	72 f2                	jb     f010156a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0101578:	5b                   	pop    %ebx
f0101579:	5d                   	pop    %ebp
f010157a:	c3                   	ret    

f010157b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010157b:	55                   	push   %ebp
f010157c:	89 e5                	mov    %esp,%ebp
f010157e:	57                   	push   %edi
f010157f:	56                   	push   %esi
f0101580:	53                   	push   %ebx
f0101581:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101584:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0101587:	eb 03                	jmp    f010158c <strtol+0x11>
		s++;
f0101589:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010158c:	0f b6 01             	movzbl (%ecx),%eax
f010158f:	3c 20                	cmp    $0x20,%al
f0101591:	74 f6                	je     f0101589 <strtol+0xe>
f0101593:	3c 09                	cmp    $0x9,%al
f0101595:	74 f2                	je     f0101589 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0101597:	3c 2b                	cmp    $0x2b,%al
f0101599:	75 0a                	jne    f01015a5 <strtol+0x2a>
		s++;
f010159b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010159e:	bf 00 00 00 00       	mov    $0x0,%edi
f01015a3:	eb 11                	jmp    f01015b6 <strtol+0x3b>
f01015a5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01015aa:	3c 2d                	cmp    $0x2d,%al
f01015ac:	75 08                	jne    f01015b6 <strtol+0x3b>
		s++, neg = 1;
f01015ae:	83 c1 01             	add    $0x1,%ecx
f01015b1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01015b6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01015bc:	75 15                	jne    f01015d3 <strtol+0x58>
f01015be:	80 39 30             	cmpb   $0x30,(%ecx)
f01015c1:	75 10                	jne    f01015d3 <strtol+0x58>
f01015c3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01015c7:	75 7c                	jne    f0101645 <strtol+0xca>
		s += 2, base = 16;
f01015c9:	83 c1 02             	add    $0x2,%ecx
f01015cc:	bb 10 00 00 00       	mov    $0x10,%ebx
f01015d1:	eb 16                	jmp    f01015e9 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01015d3:	85 db                	test   %ebx,%ebx
f01015d5:	75 12                	jne    f01015e9 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01015d7:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01015dc:	80 39 30             	cmpb   $0x30,(%ecx)
f01015df:	75 08                	jne    f01015e9 <strtol+0x6e>
		s++, base = 8;
f01015e1:	83 c1 01             	add    $0x1,%ecx
f01015e4:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01015e9:	b8 00 00 00 00       	mov    $0x0,%eax
f01015ee:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01015f1:	0f b6 11             	movzbl (%ecx),%edx
f01015f4:	8d 72 d0             	lea    -0x30(%edx),%esi
f01015f7:	89 f3                	mov    %esi,%ebx
f01015f9:	80 fb 09             	cmp    $0x9,%bl
f01015fc:	77 08                	ja     f0101606 <strtol+0x8b>
			dig = *s - '0';
f01015fe:	0f be d2             	movsbl %dl,%edx
f0101601:	83 ea 30             	sub    $0x30,%edx
f0101604:	eb 22                	jmp    f0101628 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0101606:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101609:	89 f3                	mov    %esi,%ebx
f010160b:	80 fb 19             	cmp    $0x19,%bl
f010160e:	77 08                	ja     f0101618 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0101610:	0f be d2             	movsbl %dl,%edx
f0101613:	83 ea 57             	sub    $0x57,%edx
f0101616:	eb 10                	jmp    f0101628 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0101618:	8d 72 bf             	lea    -0x41(%edx),%esi
f010161b:	89 f3                	mov    %esi,%ebx
f010161d:	80 fb 19             	cmp    $0x19,%bl
f0101620:	77 16                	ja     f0101638 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0101622:	0f be d2             	movsbl %dl,%edx
f0101625:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0101628:	3b 55 10             	cmp    0x10(%ebp),%edx
f010162b:	7d 0b                	jge    f0101638 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010162d:	83 c1 01             	add    $0x1,%ecx
f0101630:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101634:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0101636:	eb b9                	jmp    f01015f1 <strtol+0x76>

	if (endptr)
f0101638:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010163c:	74 0d                	je     f010164b <strtol+0xd0>
		*endptr = (char *) s;
f010163e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0101641:	89 0e                	mov    %ecx,(%esi)
f0101643:	eb 06                	jmp    f010164b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101645:	85 db                	test   %ebx,%ebx
f0101647:	74 98                	je     f01015e1 <strtol+0x66>
f0101649:	eb 9e                	jmp    f01015e9 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010164b:	89 c2                	mov    %eax,%edx
f010164d:	f7 da                	neg    %edx
f010164f:	85 ff                	test   %edi,%edi
f0101651:	0f 45 c2             	cmovne %edx,%eax
}
f0101654:	5b                   	pop    %ebx
f0101655:	5e                   	pop    %esi
f0101656:	5f                   	pop    %edi
f0101657:	5d                   	pop    %ebp
f0101658:	c3                   	ret    
f0101659:	66 90                	xchg   %ax,%ax
f010165b:	66 90                	xchg   %ax,%ax
f010165d:	66 90                	xchg   %ax,%ax
f010165f:	90                   	nop

f0101660 <__udivdi3>:
f0101660:	55                   	push   %ebp
f0101661:	57                   	push   %edi
f0101662:	56                   	push   %esi
f0101663:	53                   	push   %ebx
f0101664:	83 ec 1c             	sub    $0x1c,%esp
f0101667:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010166b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010166f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0101673:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0101677:	85 f6                	test   %esi,%esi
f0101679:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010167d:	89 ca                	mov    %ecx,%edx
f010167f:	89 f8                	mov    %edi,%eax
f0101681:	75 3d                	jne    f01016c0 <__udivdi3+0x60>
f0101683:	39 cf                	cmp    %ecx,%edi
f0101685:	0f 87 c5 00 00 00    	ja     f0101750 <__udivdi3+0xf0>
f010168b:	85 ff                	test   %edi,%edi
f010168d:	89 fd                	mov    %edi,%ebp
f010168f:	75 0b                	jne    f010169c <__udivdi3+0x3c>
f0101691:	b8 01 00 00 00       	mov    $0x1,%eax
f0101696:	31 d2                	xor    %edx,%edx
f0101698:	f7 f7                	div    %edi
f010169a:	89 c5                	mov    %eax,%ebp
f010169c:	89 c8                	mov    %ecx,%eax
f010169e:	31 d2                	xor    %edx,%edx
f01016a0:	f7 f5                	div    %ebp
f01016a2:	89 c1                	mov    %eax,%ecx
f01016a4:	89 d8                	mov    %ebx,%eax
f01016a6:	89 cf                	mov    %ecx,%edi
f01016a8:	f7 f5                	div    %ebp
f01016aa:	89 c3                	mov    %eax,%ebx
f01016ac:	89 d8                	mov    %ebx,%eax
f01016ae:	89 fa                	mov    %edi,%edx
f01016b0:	83 c4 1c             	add    $0x1c,%esp
f01016b3:	5b                   	pop    %ebx
f01016b4:	5e                   	pop    %esi
f01016b5:	5f                   	pop    %edi
f01016b6:	5d                   	pop    %ebp
f01016b7:	c3                   	ret    
f01016b8:	90                   	nop
f01016b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01016c0:	39 ce                	cmp    %ecx,%esi
f01016c2:	77 74                	ja     f0101738 <__udivdi3+0xd8>
f01016c4:	0f bd fe             	bsr    %esi,%edi
f01016c7:	83 f7 1f             	xor    $0x1f,%edi
f01016ca:	0f 84 98 00 00 00    	je     f0101768 <__udivdi3+0x108>
f01016d0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01016d5:	89 f9                	mov    %edi,%ecx
f01016d7:	89 c5                	mov    %eax,%ebp
f01016d9:	29 fb                	sub    %edi,%ebx
f01016db:	d3 e6                	shl    %cl,%esi
f01016dd:	89 d9                	mov    %ebx,%ecx
f01016df:	d3 ed                	shr    %cl,%ebp
f01016e1:	89 f9                	mov    %edi,%ecx
f01016e3:	d3 e0                	shl    %cl,%eax
f01016e5:	09 ee                	or     %ebp,%esi
f01016e7:	89 d9                	mov    %ebx,%ecx
f01016e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016ed:	89 d5                	mov    %edx,%ebp
f01016ef:	8b 44 24 08          	mov    0x8(%esp),%eax
f01016f3:	d3 ed                	shr    %cl,%ebp
f01016f5:	89 f9                	mov    %edi,%ecx
f01016f7:	d3 e2                	shl    %cl,%edx
f01016f9:	89 d9                	mov    %ebx,%ecx
f01016fb:	d3 e8                	shr    %cl,%eax
f01016fd:	09 c2                	or     %eax,%edx
f01016ff:	89 d0                	mov    %edx,%eax
f0101701:	89 ea                	mov    %ebp,%edx
f0101703:	f7 f6                	div    %esi
f0101705:	89 d5                	mov    %edx,%ebp
f0101707:	89 c3                	mov    %eax,%ebx
f0101709:	f7 64 24 0c          	mull   0xc(%esp)
f010170d:	39 d5                	cmp    %edx,%ebp
f010170f:	72 10                	jb     f0101721 <__udivdi3+0xc1>
f0101711:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101715:	89 f9                	mov    %edi,%ecx
f0101717:	d3 e6                	shl    %cl,%esi
f0101719:	39 c6                	cmp    %eax,%esi
f010171b:	73 07                	jae    f0101724 <__udivdi3+0xc4>
f010171d:	39 d5                	cmp    %edx,%ebp
f010171f:	75 03                	jne    f0101724 <__udivdi3+0xc4>
f0101721:	83 eb 01             	sub    $0x1,%ebx
f0101724:	31 ff                	xor    %edi,%edi
f0101726:	89 d8                	mov    %ebx,%eax
f0101728:	89 fa                	mov    %edi,%edx
f010172a:	83 c4 1c             	add    $0x1c,%esp
f010172d:	5b                   	pop    %ebx
f010172e:	5e                   	pop    %esi
f010172f:	5f                   	pop    %edi
f0101730:	5d                   	pop    %ebp
f0101731:	c3                   	ret    
f0101732:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101738:	31 ff                	xor    %edi,%edi
f010173a:	31 db                	xor    %ebx,%ebx
f010173c:	89 d8                	mov    %ebx,%eax
f010173e:	89 fa                	mov    %edi,%edx
f0101740:	83 c4 1c             	add    $0x1c,%esp
f0101743:	5b                   	pop    %ebx
f0101744:	5e                   	pop    %esi
f0101745:	5f                   	pop    %edi
f0101746:	5d                   	pop    %ebp
f0101747:	c3                   	ret    
f0101748:	90                   	nop
f0101749:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101750:	89 d8                	mov    %ebx,%eax
f0101752:	f7 f7                	div    %edi
f0101754:	31 ff                	xor    %edi,%edi
f0101756:	89 c3                	mov    %eax,%ebx
f0101758:	89 d8                	mov    %ebx,%eax
f010175a:	89 fa                	mov    %edi,%edx
f010175c:	83 c4 1c             	add    $0x1c,%esp
f010175f:	5b                   	pop    %ebx
f0101760:	5e                   	pop    %esi
f0101761:	5f                   	pop    %edi
f0101762:	5d                   	pop    %ebp
f0101763:	c3                   	ret    
f0101764:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101768:	39 ce                	cmp    %ecx,%esi
f010176a:	72 0c                	jb     f0101778 <__udivdi3+0x118>
f010176c:	31 db                	xor    %ebx,%ebx
f010176e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0101772:	0f 87 34 ff ff ff    	ja     f01016ac <__udivdi3+0x4c>
f0101778:	bb 01 00 00 00       	mov    $0x1,%ebx
f010177d:	e9 2a ff ff ff       	jmp    f01016ac <__udivdi3+0x4c>
f0101782:	66 90                	xchg   %ax,%ax
f0101784:	66 90                	xchg   %ax,%ax
f0101786:	66 90                	xchg   %ax,%ax
f0101788:	66 90                	xchg   %ax,%ax
f010178a:	66 90                	xchg   %ax,%ax
f010178c:	66 90                	xchg   %ax,%ax
f010178e:	66 90                	xchg   %ax,%ax

f0101790 <__umoddi3>:
f0101790:	55                   	push   %ebp
f0101791:	57                   	push   %edi
f0101792:	56                   	push   %esi
f0101793:	53                   	push   %ebx
f0101794:	83 ec 1c             	sub    $0x1c,%esp
f0101797:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010179b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010179f:	8b 74 24 34          	mov    0x34(%esp),%esi
f01017a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01017a7:	85 d2                	test   %edx,%edx
f01017a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01017ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01017b1:	89 f3                	mov    %esi,%ebx
f01017b3:	89 3c 24             	mov    %edi,(%esp)
f01017b6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01017ba:	75 1c                	jne    f01017d8 <__umoddi3+0x48>
f01017bc:	39 f7                	cmp    %esi,%edi
f01017be:	76 50                	jbe    f0101810 <__umoddi3+0x80>
f01017c0:	89 c8                	mov    %ecx,%eax
f01017c2:	89 f2                	mov    %esi,%edx
f01017c4:	f7 f7                	div    %edi
f01017c6:	89 d0                	mov    %edx,%eax
f01017c8:	31 d2                	xor    %edx,%edx
f01017ca:	83 c4 1c             	add    $0x1c,%esp
f01017cd:	5b                   	pop    %ebx
f01017ce:	5e                   	pop    %esi
f01017cf:	5f                   	pop    %edi
f01017d0:	5d                   	pop    %ebp
f01017d1:	c3                   	ret    
f01017d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01017d8:	39 f2                	cmp    %esi,%edx
f01017da:	89 d0                	mov    %edx,%eax
f01017dc:	77 52                	ja     f0101830 <__umoddi3+0xa0>
f01017de:	0f bd ea             	bsr    %edx,%ebp
f01017e1:	83 f5 1f             	xor    $0x1f,%ebp
f01017e4:	75 5a                	jne    f0101840 <__umoddi3+0xb0>
f01017e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01017ea:	0f 82 e0 00 00 00    	jb     f01018d0 <__umoddi3+0x140>
f01017f0:	39 0c 24             	cmp    %ecx,(%esp)
f01017f3:	0f 86 d7 00 00 00    	jbe    f01018d0 <__umoddi3+0x140>
f01017f9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01017fd:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101801:	83 c4 1c             	add    $0x1c,%esp
f0101804:	5b                   	pop    %ebx
f0101805:	5e                   	pop    %esi
f0101806:	5f                   	pop    %edi
f0101807:	5d                   	pop    %ebp
f0101808:	c3                   	ret    
f0101809:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101810:	85 ff                	test   %edi,%edi
f0101812:	89 fd                	mov    %edi,%ebp
f0101814:	75 0b                	jne    f0101821 <__umoddi3+0x91>
f0101816:	b8 01 00 00 00       	mov    $0x1,%eax
f010181b:	31 d2                	xor    %edx,%edx
f010181d:	f7 f7                	div    %edi
f010181f:	89 c5                	mov    %eax,%ebp
f0101821:	89 f0                	mov    %esi,%eax
f0101823:	31 d2                	xor    %edx,%edx
f0101825:	f7 f5                	div    %ebp
f0101827:	89 c8                	mov    %ecx,%eax
f0101829:	f7 f5                	div    %ebp
f010182b:	89 d0                	mov    %edx,%eax
f010182d:	eb 99                	jmp    f01017c8 <__umoddi3+0x38>
f010182f:	90                   	nop
f0101830:	89 c8                	mov    %ecx,%eax
f0101832:	89 f2                	mov    %esi,%edx
f0101834:	83 c4 1c             	add    $0x1c,%esp
f0101837:	5b                   	pop    %ebx
f0101838:	5e                   	pop    %esi
f0101839:	5f                   	pop    %edi
f010183a:	5d                   	pop    %ebp
f010183b:	c3                   	ret    
f010183c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101840:	8b 34 24             	mov    (%esp),%esi
f0101843:	bf 20 00 00 00       	mov    $0x20,%edi
f0101848:	89 e9                	mov    %ebp,%ecx
f010184a:	29 ef                	sub    %ebp,%edi
f010184c:	d3 e0                	shl    %cl,%eax
f010184e:	89 f9                	mov    %edi,%ecx
f0101850:	89 f2                	mov    %esi,%edx
f0101852:	d3 ea                	shr    %cl,%edx
f0101854:	89 e9                	mov    %ebp,%ecx
f0101856:	09 c2                	or     %eax,%edx
f0101858:	89 d8                	mov    %ebx,%eax
f010185a:	89 14 24             	mov    %edx,(%esp)
f010185d:	89 f2                	mov    %esi,%edx
f010185f:	d3 e2                	shl    %cl,%edx
f0101861:	89 f9                	mov    %edi,%ecx
f0101863:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101867:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010186b:	d3 e8                	shr    %cl,%eax
f010186d:	89 e9                	mov    %ebp,%ecx
f010186f:	89 c6                	mov    %eax,%esi
f0101871:	d3 e3                	shl    %cl,%ebx
f0101873:	89 f9                	mov    %edi,%ecx
f0101875:	89 d0                	mov    %edx,%eax
f0101877:	d3 e8                	shr    %cl,%eax
f0101879:	89 e9                	mov    %ebp,%ecx
f010187b:	09 d8                	or     %ebx,%eax
f010187d:	89 d3                	mov    %edx,%ebx
f010187f:	89 f2                	mov    %esi,%edx
f0101881:	f7 34 24             	divl   (%esp)
f0101884:	89 d6                	mov    %edx,%esi
f0101886:	d3 e3                	shl    %cl,%ebx
f0101888:	f7 64 24 04          	mull   0x4(%esp)
f010188c:	39 d6                	cmp    %edx,%esi
f010188e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0101892:	89 d1                	mov    %edx,%ecx
f0101894:	89 c3                	mov    %eax,%ebx
f0101896:	72 08                	jb     f01018a0 <__umoddi3+0x110>
f0101898:	75 11                	jne    f01018ab <__umoddi3+0x11b>
f010189a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010189e:	73 0b                	jae    f01018ab <__umoddi3+0x11b>
f01018a0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01018a4:	1b 14 24             	sbb    (%esp),%edx
f01018a7:	89 d1                	mov    %edx,%ecx
f01018a9:	89 c3                	mov    %eax,%ebx
f01018ab:	8b 54 24 08          	mov    0x8(%esp),%edx
f01018af:	29 da                	sub    %ebx,%edx
f01018b1:	19 ce                	sbb    %ecx,%esi
f01018b3:	89 f9                	mov    %edi,%ecx
f01018b5:	89 f0                	mov    %esi,%eax
f01018b7:	d3 e0                	shl    %cl,%eax
f01018b9:	89 e9                	mov    %ebp,%ecx
f01018bb:	d3 ea                	shr    %cl,%edx
f01018bd:	89 e9                	mov    %ebp,%ecx
f01018bf:	d3 ee                	shr    %cl,%esi
f01018c1:	09 d0                	or     %edx,%eax
f01018c3:	89 f2                	mov    %esi,%edx
f01018c5:	83 c4 1c             	add    $0x1c,%esp
f01018c8:	5b                   	pop    %ebx
f01018c9:	5e                   	pop    %esi
f01018ca:	5f                   	pop    %edi
f01018cb:	5d                   	pop    %ebp
f01018cc:	c3                   	ret    
f01018cd:	8d 76 00             	lea    0x0(%esi),%esi
f01018d0:	29 f9                	sub    %edi,%ecx
f01018d2:	19 d6                	sbb    %edx,%esi
f01018d4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01018d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01018dc:	e9 18 ff ff ff       	jmp    f01017f9 <__umoddi3+0x69>
