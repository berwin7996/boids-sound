112 => float bpm;
(60000 / (4 * bpm))::ms => dur time16;
0 => int beat;
0 => int meas;

0.5 => dac.gain;

[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0] @=> float hatNotes[];
[1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0] @=> float bdNotes[];
[0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0] @=> float snNotes[];
[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0] @=> float tomNotes[];

0 => int snareFillFlag;

OscRecv recv;
6449 => recv.port;
recv.listen();
recv.event("/note/length/distance", "i i i") @=> OscEvent @ mele;
recv.event("/drum", "i") @=> OscEvent @ drume;
 
256 => int queueSize;
0 => int queueStart;
0 => int queueEnd;
int queue[3][queueSize];

TriOsc t[4];
for(0 => int i; i < 4; i++){
    t[i] => dac;
    0.4 => t[i].gain;
}

fun void melodyRecieve(){
    while(true){
        mele => now;
        while(mele.nextMsg()){
            mele.getInt() => queue[0][queueEnd];
            mele.getInt() => queue[1][queueEnd];
            mele.getInt() => queue[2][queueEnd];
            (queueEnd + 1) % queueSize => queueEnd;
        }
    }
}

fun void drumRecieve(){
    while(true){
        drume => now;
        while(drume.nextMsg()){
            changeDrums(drume.getInt());
        }
    }
}

fun void hat(float vel){
    Noise n => HPF hi => LPF lo => dac;
    8000 => hi.freq;
    3 => hi.Q;
    18000 => lo.freq;
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
    2 => f.Q;
    for(0 => int i; i < 60; i++){
        1000 * Math.exp(-0.1 * i) + 3000 => f.freq;
        (60 - i) $ float / 60 * vel => n.gain;
        2::ms => now;
    }
}

fun void cymb(){
    Noise n => HPF hi => dac;
    6000 => hi.freq;
    3 => hi.Q;
    for(0 => int i; i < 25; i++){
        (25 - i) $ float / 25 => n.gain;
        20::ms => now;
    }
    0 => n.gain;
}

fun void melody(int note, int vel){
    SinOsc s => dac;
    note => s.freq;
    for(0 => int i; i < 100; i++){
        (100 - i) $ float / 100 => s.gain;
        2::ms => now;
    }
}

fun void changeChords(){
    if(meas % 4 == 1){
        Std.mtof(53) => t[0].freq;
        Std.mtof(60) => t[1].freq;
        Std.mtof(65) => t[2].freq;
        Std.mtof(72) => t[3].freq; 
    }
    else if(meas % 4 == 2){
        Std.mtof(55) => t[0].freq;
        Std.mtof(62) => t[1].freq;
        Std.mtof(67) => t[2].freq;
        Std.mtof(74) => t[3].freq;
    }
    else{
        Std.mtof(57) => t[0].freq;
        Std.mtof(64) => t[1].freq;
        Std.mtof(69) => t[2].freq;
        Std.mtof(76) => t[3].freq;
    }
}

fun void changeDrums(int param){
    Math.random2(0, 4) => int instChange;
    if(instChange == 0){
        [2, 3, 4, 6, 8] @=> int patLengths[];
        patLengths[Math.random2(0, 4)] => int hatPatLength;
        for(0 => int i; i < hatPatLength; i++){
            Math.randomf() => hatNotes[i];
            if(hatNotes[i] < 0.4){
                0 => hatNotes[i];
            }
        }
        for(hatPatLength => int i; i < 16; i++){
            hatNotes[i % hatPatLength] => hatNotes[i];
        }
    }
    else if(instChange == 1){
        [[1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0],
         [1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0],
         [1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0, 0],
         [1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0],
         [1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1],
         [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0],
         [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0],
         [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]] @=> int bdPats[][];
        Math.random2(0, 8) => int bdPatNum;
        for(0 => int i; i < 16; i++){
            bdPats[bdPatNum][i] => bdNotes[i];
        }
    }
    else if(instChange == 2){
        if(snareFillFlag == 0){
            Math.random2(0, 1) => snareFillFlag;
        }
    }
    else if(instChange == 3){
        Math.max(Math.min(bpm + Math.random2(-2, 2), 132), 88) => bpm;
        <<<bpm>>>;
        (60000 / (4 * bpm))::ms => time16;
    }
}

fun void beat16(){
    spork ~ hat(hatNotes[beat]);
    spork ~ bd(bdNotes[beat]);
    spork ~ sn(snNotes[beat]);
    if(beat == 0){
        changeChords();
        if(snareFillFlag == 3){
            0 => snareFillFlag;
            spork ~ cymb();
        }
    }
    if(beat % 2 == 0){
        12::ms => now;
    }
    beat++;
    if(beat == 16){
        0 => beat;
        meas++;
        if(meas == 16){
            0 => meas;
        }
        if(snareFillFlag == 1 && (meas % 4) == 3){
            for(0 => int i; i < 16; i++){
                Math.min(Math.randomf() + 0.3, 1) => snNotes[i];
                if(snNotes[i] < 0.6){
                    0 => snNotes[i];
                }
            }
            2 => snareFillFlag;
        }
        else if(snareFillFlag == 2){
            [0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0] @=> snNotes;
            changeDrums(0);
            3 => snareFillFlag;
        }

        // take out later
        changeDrums(0);
    }
}

spork ~ melodyRecieve();
spork ~ drumRecieve();

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
