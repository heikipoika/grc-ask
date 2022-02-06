samplerate = 100000 % samplerate 100ksamp/sec
bitlength = samplerate / 400 % 400 bits per sec
% Noisefloor: +/- 0.02 ; -60dB
Noisefloor = -60;
SNR = -3

b=1e-4.*[0.2915 0.8744 0.8744 0.2915]
a = [1 -2.8744 2.7565 -0.8819]

Noiseamp = 10^(Noisefloor/10)*1e5;

Sigamp = 10^(SNR/20)*Noiseamp

data=[1,0,1,0,1,1,0,0,1,0,0,1,1,0,1,0];
sig=repelem(data,bitlength);

%subplot(2,1,1)
%plot(sig)
sig = filter(b,a,sig); % channelwidth 1kHz

backg1 = Noiseamp * (complex(rand(size(sig)),rand(size(sig))) - 0.5);

backg = backg1 - backg1 .* sig;
%res=29*(0.06 * sig .* backg1 +  0.05 * backg + 0.01*sig);

res=backg + (Sigamp * sig) + (Noiseamp/1 * sig .* rand(size(sig)))

subplot(2,1,1)
plot(real(res));
subplot(2,1,2)
plot(abs(fft(res)))
%plot(sig)

f = fopen ('test.raw', 'wb');
I = real(res);
Q = imag(res);
fwrite (f, [I Q].', 'float');
fclose (f);
