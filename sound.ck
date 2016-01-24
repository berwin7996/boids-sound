112 => float bpm;
(60000 / (4 * bpm))::ms => dur time16;
0 => int beat;

[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0] @=> float hatNotes[];
[0.4, 0.2, 0.3, 0.2, 0.4, 0.2, 0.3, 0.2, 0.4, 0.2, 0.3, 0.2, 0.4, 0.2, 0.3, 0.2] @=> float hatWeights[];
[1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0] @=> float bdNotes[];
[0.4, 0.0, 0.3, 0.0, 0.4, 0.0, 0.3, 0.0, 0.4, 0.0, 0.3, 0.0, 0.4, 0.0, 0.3, 0.0] @=> float bdWeights[];
[0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0] @=> float snNotes[];
[0.0, 0.2, 0.3, 0.2, 0.6, 0.2, 0.4, 0.4, 0.0, 0.2, 0.3, 0.2, 0.6, 0.2, 0.0, 0.0] @=> float snWeights[];
[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0] @=> float tomNotes[];
[0.4, 0.2, 0.3, 0.2, 0.4, 0.2, 0.3, 0.2, 0.4, 0.2, 0.3, 0.2, 0.4, 0.2, 0.3, 0.2] @=> float tomWeights[];

OscRecv recv;
6449 => recv.port;
recv.listen();
recv.event("/note/length/distance", "i i i") @=> OscEvent @ oe;
 
256 => int queueSize;
0 => int queueStart;
0 => int queueEnd;
int queue[3][queueSize];

fun void oscr(){
    while(true){
        oe => now;
        while(oe.nextMsg()){
            oe.getInt() => queue[0][queueEnd];
            oe.getInt() => queue[1][queueEnd];
            oe.getInt() => queue[2][queueEnd];
            (queueEnd + 1) % queueSize => queueEnd;
        }
    }
}

fun void hat(float vel){
    Noise n => HPF hi => dac;
    6000 => hi.freq;
    3 => hi.Q;
    for(0 => int i; i < 25; i++){
        (25 - i) $ float / 25 * vel => n.gain;
        1::ms => now;
    }
    0 => n.gain;
}

fun void bd(float vel){
    TriOsc k => dac;
    vel * 1.5 => k.gain;
    for(0 => int i; i < 40; i++){
        50 * Math.exp(-0.1 * i) + 50 => k.freq;
        (40 - i) $ float / 40 * vel * 1.5 => k.gain;
        5::ms => now;
    }
}

fun void sn(float vel){
    Noise n => LPF f => dac;
    1.5 => f.Q;
    for(0 => int i; i < 50; i++){
        1000 * Math.exp(-0.1 * i) + 3000 => f.freq;
        (50 - i) $ float / 50 * vel => n.gain;
        2::ms => now;
    }
}

fun void melody(int note, int vel){
    SinOsc s => dac;
    note => s.freq;
    for(0 => int i; i < 100; i++){
        (100 - i) $ float / 100 => s.gain;
        2::ms => now;
    }
}

fun void beat16(){
    spork ~ hat(hatNotes[beat] * hatWeights[beat]);
    spork ~ bd(bdNotes[beat] * bdWeights[beat]);
    spork ~ sn(snNotes[beat] * snWeights[beat]);
    beat++;
    if(beat == 16){
        0 => beat;
        Math.random2(0, 2) => int instChange;
        Math.random2(0, 15) => int beatIndex;
        if(instChange == 0){
            Math.random2(0, 2) $ float / 2 => hatNotes[beatIndex];
        }
        else if(instChange == 1){
            Math.random2(0, 2) $ float / 2 => bdNotes[beatIndex];
        }
        else if(instChange == 2){
            Math.random2(0, 2) $ float / 2 => snNotes[beatIndex];
        }
    }
}

spork ~ oscr();

while(true){
    beat16();
    if(queueStart != queueEnd){
        spork ~ melody(queue[0][queueStart], queue[1][queueStart]);
        (queueStart + 1) % queueSize => queueStart;
        time16 => now;
        beat16();
        if(queueStart != queueEnd){
            spork ~ melody(queue[0][queueStart], queue[1][queueStart]);
            (queueStart + 1) % queueSize => queueStart;
        }
    }
    else{
        time16 => now;
        beat16();
    }
    time16 => now;
}
