"""
MIPS Simulator 0.2
Author: Brian Reily
Download: www.brianreily.com/media/code/simulator.py

License:  Use/Modify/Whatever, but credit would be sweet.

Classes:
Simulator -- Used to simulate MIPS code
"""
import re, sys

class Simulator:
    """ Simulates MIPS code.  Set verbose to True to get lots of
        output.  mem sets the memory size, the default being 1000
        bytes (250 words if you act like it's word-aligned).  pc sets
        the default start value.  Default is 0, in which case it
        starts at the first line.  Use run_lines([]) to run
        multiple lines of code.  Use run_line to run just one.
        Use get_register('$s3') to get the value there; likewise
        with get_data(address).  Use reset() to set everything to
        default and clear code, or rerun() to run the same instructions.

        .data directives are not supported yet, enter data
        manually before starting program.

        Available operations: syscall, j, b, jr, beq, bne, lw, sw,
        slt, slti, add, addi, sub, subi, and, andi, or, ori, sll,
        sllv, srl, srlv, div, mul, xor, xori, move"""

    def __init__(self, verbose=False, mem=4096, pc=0):
        self.verbose = verbose
        self.data = [0 for x in range(mem)]
        self.pc = pc
        self.bfc = 3217031168
        self.hi = 0
        self.lo = 0
        self.instructions = []
        self.labels = {}
        self.registers = { '$0' : 0, '$at': 0, '$v0': 0, '$v1': 0,
                           '$a0': 0, '$a1': 0, '$a2': 0, '$a3': 0,
                           '$t0': 0, '$t1': 0, '$t2': 0, '$t3': 0,
                           '$t4': 0, '$t5': 0, '$t6': 0, '$t7': 0,
                           '$s0': 0, '$s1': 0, '$s2': 0, '$s3': 0,
                           '$s4': 0, '$s5': 0, '$s6': 0, '$s7': 0,
                           '$t8': 0, '$t9': 0, '$k0': 0, '$k1': 0,
                           '$gp': 0, '$sp': 0, '$s8': 0, '$ra': 0 }

        self.register_list = ['$0', '$at', '$v0', '$v1', '$a0', '$a1',
            '$a2', '$a3', '$t0', '$t1', '$t2', '$t3', '$t4', '$t5', '$t6',
            '$t7', '$s0', '$s1', '$s2', '$s3', '$s4', '$s5', '$s6', '$s7',
            '$t8', '$t9', '$k0', '$k1', '$gp', '$sp', '$s8', '$ra']

        self.function_lookup = {'add':'+',   'addi':'+',  'addiu':'+',  'sub':'-',      'lui':'<<',
                                'subi':'-',  'and':'&',   'andi':'&',   'or':'|',       'ori':'|',
                                'sll':'<<',  'sllv':'<<', 'srl':'>>',   'srlv':'>>',    'sra':'>>',
                                'div':'/',   'mult':'*',  'xor':'^',    'xori':'^',     'srav':'>>',
                                'multu':'*', 'subu':'-',  'addu':'+',   'divu':'/',     'multu':'*'}

    def get_register(self, register):
        """Retrieve value of a register; Accepts $vo or $2."""
        try: return self.registers[register]
        except:
            try:
                register = register.strip('$')
                return self.registers[self.register_list[int(register)]]
            except:
                try: return self.registers[self.register_list[register]]
                except: return None

    def status(self):
        """Prints current status of the machine."""
        for register in self.register_list[:8]:
            print('%3s: %4s' %(register, self.registers[register]))
        print()
        for register in self.register_list[8:16]:
            print('%3s: %4s' %(register, self.registers[register]))
        print()
        for register in self.register_list[16:24]:
            print('%3s: %4s' %(register, self.registers[register]))
        print()
        for register in self.register_list[24:32]:
            print('%3s: %4s' %(register, self.registers[register]))
        print()
        for i, instruction in enumerate(self.instructions[10:]):
            print('%3s: %s' %(i+10, instruction))
        print('Current PC: %s'%(self.pc))

    def run_lines(self, lines):
        """External method to run multiple lines."""
        lines = self.strip_comments(lines)
        self.instructions.extend(lines)
        self.find_labels(lines)
        while self.pc < len(self.instructions):
            line = self.instructions[self.pc]
            print('Running line %s: %s' %(self.pc, line))
            if 'halt' in line:
                self.pc = 0
                break
            self.execute(line)
            self.pc += 1

    def run_line(self, line):
        """External method to execute one line."""
        try: line = self.strip_comments([line])[0]
        except:
            print("Can't execute comments")
            return
        self.execute(line)
        self.pc += 1
        self.instructions.append(line)

    def execute(self, line):
        """Internal method to execute a line of code."""
        # if self.verbose: print( '%s: %s' )%(self.pc, line),
        if re.compile('^.*:').match(line): return
        elif re.compile('^syscall').match(line): self.syscall()
        elif re.compile('^(beq|bne|bgez|bgezal|bgtz|blez|bltz|bltzal)').match(line):
            self.branch(line)
        elif re.compile('^(j|b|jr|jal|jalr)\s.*').match(line): self.jump(line)
        elif re.compile('^(sw|sb|sh|lw|lb|lbu|lh|lhu|lwl|lwr)\s.*').match(line): self.load_store(line)
        elif re.compile('^(slt|slti|sltiu|sltu)\s\$.{1,2},\s\$.{1,2},.*').match(line):
            self.set_less_than(line)
        elif re.compile('^(mthi|mtlo).*').match(line): self.move(line) # MTHI and MTLO move functions to implement
        elif re.compile('^[a-zA-Z]{2,5}\s\$.{1,2},\s\$.{1,2},.*').match(line):
            self.logical_arithmetic(line)
        elif re.compile('^(lui|div|divu|mult|multu)\s').match(line):
            self.logical_arithmetic(line)

    def logical_arithmetic(self, line): # sra, srav
        """The majority of instructions: add, or, etc."""
        # print 'logical_arithmetic() function called'
        instr = re.compile('^[a-zA-Z]{2,6}\s').findall(line)[0].strip()
        func = self.function_lookup[instr]
        if instr == 'lui': # rt=imm<<16
            rt = re.compile('\$.{1,2}').findall(line)[0]
            imm = re.findall(r'\s-?\d+', line)[0].strip()
            self.registers[rt] = eval(str(imm) + func + '16')
        else:
            reg = [f.strip(' ,') for f in re.compile('\$.{1,2}').findall(line)]
            r1, r2 = reg[0], reg[1]
            if instr in ('div', 'divu', 'mult', 'multu'):
                print "multiplication or division method called."
                if instr in ('div', 'mult'):
                    rs_val = self.get_register(r1)
                    rt_val = self.get_register(r2)
                else:
                    rs_val = self.get_register(r1)
                    rt_val = self.get_register(r2)
                self.hi = self.lo = eval(str(rs_val) + func + str(rt_val))
                if instr in ('div', 'divu'):
                    self.hi = eval(str(rs_val) + func + str(rt_val))
            elif 'i' in instr[2:] or instr in ('sll', 'srl'):
                imm = re.findall(r'\s-?\d+', line)[0].strip()
                if int(imm) > 2**15 - 1:
                    print("invalid immediate value")
                elif int(imm) > 2**14 - 1:
                    imm = int(format(int(imm), 'b').zfill(16), 2)
                self.registers[r1] = eval(str(self.get_register(r2)) + func + str(imm))
            elif instr == 'sra': # rd=rt>>sa
                imm = re.findall(r'\s-?\d+', line)[0].strip()
                try:
                    imm = int(imm)
                except:
                    imm = 0
                rt_val = self.get_register(r2)
                rt_val_bin = format(rt_val & 0xffffffff, 'b').zfill(32) # convert to two's complement binary
                if rt_val_bin[0] == '1':
                    rd_val = ('1'*imm) + rt_val_bin[:(32-imm)]
                    rd_val = int(rd_val, 2) # convert to signed integer
                else:
                    rd_val = eval(str(rt_val) + func + str(imm))
                self.registers[r1] = rd_val
            else:
                r3 = reg[2]
                if instr == 'srav': # rd=rt>>rs
                    rt_val = self.get_register(r2)
                    rs_val = self.get_register(r3)
                    rt_val_bin = format(rt_val & 0xffffffff, 'b').zfill(32)
                    if rt_val_bin[0] == '1':
                        rd_val = ('1'*int(rs_val)) + rt_val_bin[rs_val:]
                        rd_val = int(rd_val, 2)-(1<<32) # convert to signed integer
                    else:
                        rd_val = eval(str(rt_val) + func + str(rs_val))
                    self.registers[r1] = rd_val
                else:
                    self.registers[r1] = eval(str(self.get_register(r2)) + func +
                                            str(self.get_register(r3)))
                # if self.verbose: print '\t# %s = %s %s %s = %s' %(r1,
                #     self.get_register(r2), func, self.get_register(r3), self.get_register(r1))

    def move(self, line): # mthi, mtlo
        """The move instruction."""
        instr = re.compile('^[a-zA-Z]{2,5}\s').findall(line)[0].strip()
        reg = re.compile('\$.{1,2}').findall(line)[0]
        if instr == 'mthi':
            self.hi = self.get_register(reg)
        elif instr == 'mtlo':
            self.lo = self.get_register(reg)
        else:
            print('instruction regex error')
        # if self.verbose: print '\t# %s = %s' %(r1, self.get_register(r1))

    def set_less_than(self, line):
        """Set register to 1 if true."""
        reg = [f.strip(' ,') for f in re.compile('\$.{1,2}').findall(line)]
        
        if len(reg) == 3 and line[:4] == 'slt ':
            r1, r2, r3 = reg[0], reg[1], reg[2]
            if self.get_register(r2) < self.get_register(r3):
                self.registers[r1] = 1
                # if self.verbose: print '\t# %s < %s, so %s = 1' %(
                    # self.get_register(r2), self.get_register(r3), r1)
            else:
                self.registers[r1] = 0
                # if self.verbose: print '\t# %s !< %s, so %s = 0' %(
                    # self.get_register(r2), self.get_register(r3), r1)
                    
        elif len(reg) == 3 and line[:4] == 'sltu':                      #new
            r1, r2, r3 = reg[0], reg[1], reg[2]
            if self.get_register(r2) < self.get_register(r3):
                self.registers[r1] = 1
                # if self.verbose: print '\t# %s < %s, so %s = 1' %(
                    # self.get_register(r2), self.get_register(r3), r1)
            else:
                self.registers[r1] = 0
                # if self.verbose: print '\t# %s !< %s, so %s = 0' %(
                    # self.get_register(r2), self.get_register(r3), r1)

        elif len(reg) == 2 and line[:5] == 'slti ':
            r1, r2 = reg[0], reg[1]
            imm = re.findall(r'\s-?\d+', line)[0].strip()
            # imm = line.lstrip('slti ').lstrip(r1 + ', ').lstrip(r2 + ',')
            imm = int(imm)
            if self.get_register(r2) < imm:
                self.registers[r1] = 1

                # if self.verbose: print '\t# %s < %s, so %s = 1' %(
                    # self.get_register(r2), imm, r1)
            else:
                self.registers[r1] = 0
                # if self.verbose: print '\t# %s !< %s, so %s = 0' %(
                    # self.get_register(r2), imm, r1)
                    
        elif len(reg) == 2 and line[:5] == 'sltiu':                         #new 
            r1, r2 = reg[0], reg[1]
            imm = re.findall(r'\s-?\d+', line)[0].strip()
            imm = int(imm)
            if self.get_register(r2) < imm:
                self.registers[r1] = 1
                print(imm) #remove
            else:
                self.registers[r1] = 0
                print(imm) #remove



    def load_store(self, line):
        """Handles lw and sw instructions."""
        part = line.lstrip('sw ').lstrip('lw ').lstrip('lb ').lstrip('lbu ').lstrip('lh ')\
            .lstrip('lhu ').lstrip('lwl ').lstrip('lwr ').lstrip('sb ').lstrip('sh ')
        reg = re.compile('(\$.{1,2})').findall(line)[0].strip(' ,')
        if line[:2] == 'sw':
            try:
                offset = int(re.compile('\d+\(').findall(line)[0].rstrip('('))
            except:
                offset = 0
            addr = re.compile('\(\$.{1,2}\)').findall(line)[0].strip('(').strip(')')
            addr = self.get_register(addr) - self.bfc + offset
            word = format(self.get_register(reg) & 0xffffffff, 'b').zfill(32) # Two's complement
            self.data[addr+3] = int(word[0:8], 2)
            self.data[addr+2] = int(word[8:16], 2)
            self.data[addr+1] = int(word[16:24], 2)
            self.data[addr]   = int(word[24:32], 2)
            # print word
            # if self.verbose: print '\t# Store %s in data[%s]' %(
            #     self.get_register(reg), addr)
        elif line[:2] == 'sb': # *(char*)(offset+rs)=rt
            try:
                offset = int(re.compile('\d+\(').findall(line)[0].rstrip('('))
            except:
                offset = 0
            addr = re.compile('\(\$.{1,2}\)').findall(line)[0].strip('(').strip(')')
            addr = self.get_register(addr) - self.bfc + offset
            byte = format(self.get_register(reg) & 0xffffffff, 'b').zfill(8)[-8:] # This assumes that the data is less than a byte
            self.data[addr] = int(byte, 2)
        elif line[:2] == 'sh': # *(short*)(offset+rs)=rt
            try:
                offset = (int(re.compile('\d+\(').findall(line)[0].rstrip('('))//2)*2
            except:
                offset = 0
            addr = re.compile('\(\$.{1,2}\)').findall(line)[0].strip('(').strip(')')
            addr = self.get_register(addr) - self.bfc + offset
            hword = format(self.get_register(reg) & 0xffffffff, 'b').zfill(16)[-16:] # This assumes that the data is less than a half word
            self.data[addr+1] = int(hword[0:8], 2)
            self.data[addr]   = int(hword[8:16], 2)
        elif line[:3] == 'lw ':
            try:
                offset = int(re.compile('\d+\(').findall(line)[0].rstrip('('))
            except:
                offset = 0
            addr = re.compile('\(\$.{1,2}\)').findall(line)[0].strip('(').strip(')')
            addr = self.get_register(addr) - self.bfc + offset
            bin_str = format(self.data[addr+3], 'b').zfill(8) + \
                format(self.data[addr+2], 'b').zfill(8) + \
                format(self.data[addr+1], 'b').zfill(8) + \
                format(self.data[addr], 'b').zfill(8)
            if bin_str[0] == '1': # sign-extension
                word = int(bin_str, 2) - (1<<32) # two's complement negative number
            else:
                word = int(bin_str, 2)
            self.registers[reg] = word # word is already an integer type
            # if self.verbose: print '\t# Load %s from data[%s]' %(
                # self.get_register(reg), addr)
        elif line[:3] == 'lb ': # rt=*(char*)(offset+rs) !!! 'lb' instruction is sign-extended
            try:
                offset = int(re.compile('\d+\(').findall(line)[0].rstrip('('))
            except:
                offset = 0
            addr = re.compile('\(\$.{1,2}\)').findall(line)[0].strip('(').strip(')')
            addr = self.get_register(addr) - self.bfc + offset
            byte = format(self.data[addr], 'b').zfill(8)
            if byte[0] == '1': # sign-extending
                word = format(0xffffff, 'b') + byte
            else:
                word = byte.zfill(32)
            self.registers[reg] = int(word, 2)
        elif line[:3] == 'lbu': # rt=*(Uchar*)(offset+rs) !!! 'lbu' instruction is zero-extended
            try:
                offset = int(re.compile('\d+\(').findall(line)[0].rstrip('('))
            except:
                offset = 0
            addr = re.compile('\(\$.{1,2}\)').findall(line)[0].strip('(').strip(')')
            addr = self.get_register(addr) - self.bfc + offset
            word = format(self.data[addr], 'b').zfill(32) # simple zero-extension
            self.registers[reg] = int(word, 2)
        elif line[:3] == 'lh ': # rt=*(short*)(offset+rs) !!! 'lh' instruction is sign-extended
            try:
                offset = int(re.compile('\d+\(').findall(line)[0].rstrip('('))
            except:
                offset = 0
            addr = re.compile('\(\$.{1,2}\)').findall(line)[0].strip('(').strip(')')
            addr = self.get_register(addr) + offset - self.bfc
            hword = format(self.data[addr+1], 'b').zfill(8) + \
                format(self.data[addr], 'b').zfill(8)
            if hword[0] == '1': # sign-extension
                word = format(0xffff, 'b') + hword
                word = int(word, 2) # - (1<<32)
            else:
                word = hword.zfill(32)
                word = int(word, 2)
            self.registers[reg] = word
        elif line[:3] == 'lhu': # rt=*(Ushort*)(offset+rs) !!! 'lhu' instruction is zero-extended
            try:
                offset = int(re.compile('\d+\(').findall(line)[0].rstrip('('))
            except:
                offset = 0
            addr = re.compile('\(\$.{1,2}\)').findall(line)[0].strip('(').strip(')')
            addr = self.get_register(addr) + offset - self.bfc
            hword = format(self.data[addr+1], 'b').zfill(8) + \
                format(self.data[addr], 'b').zfill(8)
            word = hword.zfill(32) # simple zero-extension
            self.registers[reg] = int(word, 2)
        # https://stackoverflow.com/questions/57522055/what-do-the-mips-load-word-left-lwl-and-load-word-right-lwr-instructions-do
        elif line[:3] == 'lwl': # rt=*(int*)(offset+rs) !!! offset only between 0-3
            try:
                offset = int(re.compile('\d+\(').findall(line)[0].rstrip('('))
            except:
                offset = 0
            addr = re.compile('\(\$.{1,2}\)').findall(line)[0].strip('(').strip(')')
            addr = self.get_register(addr) - self.bfc
            if offset == 3:
                content = format(self.data[addr], 'b').zfill(8)
                reg_val = format(self.get_register(reg), 'b').zfill(32)
                word = content + reg_val[8:32]
            elif offset == 2:
                content = format(self.data[addr+1], 'b').zfill(8) + \
                    format(self.data[addr], 'b').zfill(8)
                reg_val = format(self.get_register(reg), 'b').zfill(32)
                word = content + reg_val[16:32]
            elif offset == 1:
                content = format(self.data[addr+2], 'b').zfill(8) + \
                    format(self.data[addr+1], 'b').zfill(8) + \
                    format(self.data[addr], 'b').zfill(8)
                reg_val = format(self.get_register(reg), 'b').zfill(32)
                word = content + reg_val[24:32]
            elif offset == 0:
                word = format(self.data[addr+3], 'b').zfill(8) + \
                    format(self.data[addr+2], 'b').zfill(8) + \
                    format(self.data[addr+1], 'b').zfill(8) + \
                    format(self.data[addr], 'b').zfill(8)
            else:
                print("invalid offset value")
            self.registers[reg] = int(word, 2)
        elif line[:3] == 'lwr':
            try:
                offset = int(re.compile('\d+\(').findall(line)[0].rstrip('('))
            except:
                offset = 0
            addr = re.compile('\(\$.{1,2}\)').findall(line)[0].strip('(').strip(')')
            addr = self.get_register(addr) - self.bfc
            if offset == 0:
                word = str(self.get_register(reg))
            elif offset == 1:
                content = format(self.data[addr+7], 'b').zfill(8)
                reg_val = str(self.get_register(reg))
                word = reg_val[0:24] + content
            elif offset == 2: 
                content = format(self.data[addr+7], 'b').zfill(8) + \
                    format(self.data[addr+6], 'b').zfill(8)
                reg_val = str(self.get_register(reg))
                word = reg_val[0:16] + content
            elif offset == 3:
                content = format(self.data[addr+7], 'b').zfill(8) + \
                    format(self.data[addr+6], 'b').zfill(8) + \
                    format(self.data[addr+5], 'b').zfill(8)
                reg_val = str(self.get_register(reg))
                word = reg_val[0:8] + content
            else:
                print("invalid offset value")
            self.registers[reg] = int(word, 2)



    def branch(self, line):
        """Handles beq and bne instructions."""
        rs = re.compile('\$.{1,2}').findall(line)[0]
        offset = re.compile(' \d{1,2}?').findall(line)[0].lstrip()
        if re.compile('^bgez +\$.*').match(line): # if(rs>=0) pc+=offset*4
            if self.get_register(rs) >= 0:
                self.pc += int(offset) - 1 # added -1
        elif re.compile('^bgezal +\$.*').match(line): # r31=pc; if(rs>=0) pc+=offset*4
            self.registers['$ra'] = self.bfc+((self.pc+2)*4) # r31=pc 
            if self.get_register(rs) >= 0:
                self.pc += int(offset) - 1 # added -1 thursday
        elif re.compile('^bgtz +\$.*').match(line): # if(rs>0) pc+=offset*4
            if self.get_register(rs) > 0:
                self.pc += int(offset) - 1 # added -1
        elif re.compile('^blez +\$.*').match(line): # if(rs<=0) pc+=offset*4
            if self.get_register(rs) <= 0:
                self.pc += int(offset) - 1 # added -1
        elif re.compile('^bltz +\$.*').match(line): # if(rs<0) pc+=offset*4
            if self.get_register(rs) < 0:
                self.pc += int(offset) - 1 # added -1
        elif re.compile('^bltzal +\$.*').match(line): # r31=pc; if(rs<0) pc+=offset*4
            self.registers['$ra'] = self.bfc+((self.pc+2)*4) # r31=pc
            if self.get_register(rs) < 0:
                self.pc += int(offset) - 1 # added -1
        else:
            reg = [r.strip(', ') for r in re.compile('\$.{1,2}').findall(line)]
            r1, r2 = reg[0], reg[1]
            # imm = line.lstrip('^(beq|bne)\s').lstrip(r1 + ', ').lstrip(r2 + ', ')  #benq???
            if self.get_register(r1) == self.get_register(r2): # beq
                # if self.verbose: print '\t# %s == %s, ' %(r1, r2),
                if line[:3] == 'beq':
                    try:
                        self.pc += int(offset) - 1 # added -1 
                    except:
                        if self.verbose: print('can\'t find label')
                else:
                    if self.verbose: print('not branching')
            else:
                # if self.verbose: print '\t# %s != %s, ' %(r1, r2),
                if line[:3] == 'bne':
                    try:
                        self.pc += int(offset) - 1 # added -1
                    except:
                        if self.verbose: print('can\'t find label')
                else:
                    if self.verbose: print('not branching')

    def jump(self, line): 
        """Handles jr, j and b instructions."""
        if re.compile('^jr\ +\$.*').match(line):
            register = line.lstrip('jr ')
            # if self.verbose: print '\t# Old PC = %s, New PC = %s' %(
                # self.pc, self.get_register(register))
            self.pc = (self.get_register(register)-self.bfc)/4 - 1 #added -1
        elif re.compile('^j\ ').match(line): # pc=pc_upper|(target<<2)
            imm = re.compile(' \d').findall(line)[0].strip()
            try:
                imm = int(imm) # used to be - bfc (dont need)
            except:
                imm = self.pc + 1
            self.pc += imm
        elif re.compile('^jal ').match(line): # r31=pc; pc=target<<2
            imm = re.findall(r'\s-?\d+', line)[0].strip()
            print("imm : %s" % imm)
            try:
                imm = int(imm)
            except:
                imm = self.pc + 1
            self.registers['$ra'] = self.bfc+((self.pc+2)*4)
            self.pc = (int(format(0xb, 'b') + format((imm<<2), 'b'), 2) - self.bfc)/4-1
        elif re.compile('^jalr ').match(line): # rd=pc; pc=rs
            rd, rs = re.compile('\$.{1,2}').findall(line)
            self.registers[rd] = self.bfc+((self.pc+2)*4)
            self.pc = (self.get_register(rs)-self.bfc)/4-1 #added -1
        else:
            label = line[2:].strip()
            if label in self.labels:
                # if self.verbose: print '\t# Old PC = %s' %self.pc,
                self.pc = self.labels[label]
                # if self.verbose: print ', New PC = %s' %self.pc
            else: print('\t# Label not found, PC = %s' %self.pc)

    def syscall(self):
        """ Action based on value in $v0:
            1:  Print int in $a0
            5:  Read int into $v0
            10: Exit"""
        print('syscall(%s)' %self.get_register('$v0'))
        # if self.verbose: print '\t# $v0 = %s, $a0 = %s' %(
        #     self.get_register('$v0'), self.get_register('$a0'))
        # if self.get_register('$v0') == 1: print(self.get_register('$a0'))
        # if self.get_register('$v0') == 5:
            # self.registers['$v0'] = raw_input('read > ')
        # if self.get_register('$v0') == 10: sys.exit()

    def rerun(self):
        """Rerun all instructions in memory."""
        lines = self.instructions 
        self.pc = self.bfc # 0xBFC00000
        self.instructions = []
        self.run_lines(lines)

    def reset(self):
        """Reset everything to defaults."""
        self.instructions = []
        self.labels = {}
        self.pc = self.bfc # 0xBFC00000
        self.data = [0 for x in range(4096)]
        for r in self.register_list:
            self.registers[r] = 0

    def strip_comments(self, lines):
        """Strips out comments from a list of lines."""
        ret = []
        for line in lines:
            if '#' in line: line = line[:line.find('#')]
            line = line.strip().strip('\n')
            if len(line) < 2: continue
            ret.append(line)
        return ret

    def find_labels(self, lines):
        """Records all labels in program."""
        for i, line in enumerate(lines):
            if re.compile('^.*:').match(line):
                self.labels[line.strip().rstrip(':')] = i

    def __repr__(self):
        return '< Simulator -- PC: %s >' %self.pc
