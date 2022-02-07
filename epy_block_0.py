"""
Python ASK Demodulate
Deserialize Sink
Takes a bit stream, searches for the sync sequence 0b1010 and outputs all data until trailing sync
"""

import numpy as np
import sys

from gnuradio import gr

class blk(gr.sync_block):  # other base classes are basic_block, decim_block, interp_block
    """Embedded Python Block example - a simple multiply const"""

    def __init__(self):  # only default arguments here
        """arguments to this function show up as parameters in GRC"""
        gr.sync_block.__init__(
            self,
            name='Python ASK Demod',
            in_sig=[np.byte],
            out_sig=None
        )
        
        self.buffer = np.byte(0)
        self.cnt = 0
        self.msg_start = 0
        self.msg_cnt = 0
        
        

    def work(self, input_items, output_items):
        if np.any(input_items[0][:] > 0):
            
            n = 0
            if self.msg_start == 0:
                self.cnt = 0
                self.buffer = 0
                while (input_items[0][n] == 0): # search the first set bit
                    n = n + 1
                
            for i in range (n, len(input_items[0])):
                self.buffer = (self.buffer << 1) | (input_items[0][i] & 0x01) # Pack nibble
                self.cnt = self.cnt + 1
                if self.cnt == 4:
                    self.cnt = 0
                    
                    if self.buffer == 0x0a:   # Channel open/close
                        if self.msg_start == 0:
                            self.msg_start = 1
                            sys.stdout.write("!")
                            self.msg_cnt = 0
                        else:
                            self.msg_start = 0
                            self.msg_cnt = 0
                            sys.stdout.write("*") 
                    else:
                        if (self.msg_start == 1) and (self.msg_cnt < 12):
                            self.msg_cnt = self.msg_cnt + 1
                            sys.stdout.write("%x " % self.buffer) # Print if in between open close
                        else:
                            self.msg_cnt = 0
                            self.msg_start = 0
                    self.buffer = 0
                
        return len(input_items[0])
