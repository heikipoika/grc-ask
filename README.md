# grc-ask
Decode ASK modulated data

Decodeing a digital stream encoded as CW "morse code" is actually not as simple as it might appear. Even though your ASK modulation scheme might seem simple 
using only a fix length pulse for '1' and the same fixed gap for a '0', you'll place yourself in a clock recovery issue. This issue is adressed with various
only slightly more complex modulation schemes. One being OOK, as used in a previous project of mine: https://github.com/heikipoika/grc-ook .
This modulation has an edge (low/high transition) in every bit which is used as reference for when to sample the databit value.

## Clock Recovery

However, theres some nice readymade blocks for clock recovery in grc, intended for more complex issues than a low bandwidth datalink over HF. The intent
of this project is just to try it out.


 
