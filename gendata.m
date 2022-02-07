samplerate = 100000 % samplerate 100ksamp/sec
symbolrate = 400 % 400 bits per sec
Noisefloor = -60
SNR = -3
ampvar = 0 % 0.4
jitt = 0 % 0.1
msg = 'AC9B645F69A00'


data1 = dec2bin(hex2dec(msg));

data = zeros(1,length(data1));
for i = 1:length(data1)
    data(i) = str2num(data1(i));
end

bitlength = samplerate / symbolrate; 
pwjitt = int16(jitt*bitlength);

%butterworth lowpass 1kHz cutoff
b = 1e-4.*[0.2915 0.8744 0.8744 0.2915];
a = [1 -2.8744 2.7565 -0.8819];

Noiseamp = 10^(Noisefloor/10)*1e5;

Sigamp = 10^(SNR/20)*Noiseamp;

%data=[1,0,1,0,1,1,0,0,1,0,0,1,1,0,1,0]
sig=repelem(data,bitlength);

amplitude = ones(1,length(sig));
amplitude(1:length(sig)/4) = 1-ampvar;
amplitude(length(sig)/4:length(sig)/2) = 1-ampvar/2;
amplitude(length(sig)/2:length(sig)-(length(sig)/4)) = 1;
amplitude(length(sig)-(length(sig)/4):length(sig)) = 1-ampvar;

if pwjitt >2
    sig_right = [zeros(1, pwjitt-1) sig(pwjitt:length(sig))];
    sig_left = [sig(pwjitt:length(sig)) zeros(1, pwjitt-1)];
    
    sig_short = sig & sig_right & sig_left;
    sig_long = sig | sig_right | sig_left;
    
    sig_comb = [sig_short(1:length(floor(sig_short)/2)-1) sig_long(length(floor(sig_short)/2)-1:length(sig_short)-1)];
else
    sig_comb = sig;
end

sig = filter(b,a,sig_comb); % channelwidth 1kHz

%backg1 = Noiseamp * (complex(rand(size(sig)),rand(size(sig))) - 0.5);
backg1 = Noiseamp * (rand(size(sig)) - 0.5);
backg1_i = Noiseamp * (rand(size(sig)) - 0.5);

backg = backg1 - backg1 .* sig;
backg_i = backg1_i - backg1_i .* sig;

%res=backg + (Sigamp * (amplitude .* sig)) + (Noiseamp/1 * sig .* rand(size(sig)));
res1=backg + (Sigamp * (amplitude .* sig)) + (Noiseamp/1 * sig .* rand(size(sig)));
res2=backg + (Sigamp * (amplitude .* sig)) + (Noiseamp/1 * sig .* rand(size(sig)));

res=complex(res1,res2);

subplot(2,1,1);
plot(imag(res));
subplot(2,1,2);
plot(real(res));


f = fopen ('matlab_IQ.raw', 'wb');
I = real(res);
Q = imag(res);
fwrite (f, [I Q].', 'float');
fclose (f);
