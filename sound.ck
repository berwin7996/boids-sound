112 => float bpm;
(60000 / (4 * bpm))::ms => dur time16;
0 => int beat;
0 => int meas;
60 => int key;
0 => int lastId;
0 => int chordPullFlag;

0.15 => dac.gain;

[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0] @=> float hatNotes[];
[1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0] @=> float bdNotes[];
[0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0] @=> float snNotes[];
[1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0] @=> float tomNotes[];

0 => int snareFillFlag;

OscRecv recv;
9433 => recv.port;
recv.listen();
recv.event("/collision", "i f f f f f f f") @=> OscEvent @ mele;
recv.event("/drum", "i") @=> OscEvent @ drume;

OscRecv recv2;
9438 => recv2.port;
recv2.listen();
recv2.event("/chord", "i i i i i i") @=> OscEvent @ chorde;

OscSend xmit;
xmit.setHost("127.0.0.1", 9437);

16 => int queueSize;
0 => int queueStart;
0 => int queueEnd;
int queue[3][queueSize];
0 => int chordQueueStart;
0 => int chordQueueEnd;
int chordQueue[6][queueSize];

SinOsc bass => dac;
0.9 => bass.gain;

TriOsc t[4];
Pan2 tpan[4];
for(0 => int i; i < 4; i++){
    t[i] => tpan[i] => dac;
    0.35 => t[i].gain;
    -1.0 + (2.0 * i / 3.0) => tpan[i].pan;
}

fun void melodyRecieve(){
    while(true){
        mele => now;
        while(mele.nextMsg()){
            mele.getInt() => int id;
            if(id != lastId){
                id => queue[0][queueEnd];
                mele.getFloat();
                mele.getFloat() $ int => queue[2][queueEnd];
                mele.getFloat() $ int => queue[1][queueEnd];
                for(4 => int i; i < 8; i++){
                    mele.getFloat();
                }
                (queueEnd + 1) % queueSize => queueEnd;
            }
            else{
                for(1 => int i; i < 8; i++){
                    mele.getFloat();
                }
            }
            id => lastId;
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

fun void chordRecieve(){
    while(true){
        chorde => now;
        while(chorde.nextMsg()){
            for(0 => int i; i < 6; i++){
                chorde.getInt() => chordQueue[i][chordQueueEnd];
            }
            (chordQueueEnd + 1) % queueSize => chordQueueEnd;
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
    bass.freq() + Math.random2f(-0.2, 0.2) => float bassFreq;
    if(bassFreq > 78){
        bassFreq / 2 => bassFreq;
    }
    for(0 => int i; i < 40; i++){
        50 * Math.exp(-0.07 * i) + bassFreq => k.freq;
        (40 - i) $ float / 20 * vel => k.gain;
        5::ms => now;
    }
}

fun void sn(float vel){
    Noise n => LPF f => dac;
    1.7 => f.Q;
    for(0 => int i; i < 50; i++){
        1200 * Math.exp(-0.1 * i) + 3400 => f.freq;
        (50 - i) $ float / 90 * vel => n.gain;
        2::ms => now;
    }
}

fun void cymb(){
    Noise n => HPF hi => dac;
    6000 => hi.freq;
    3 => hi.Q;
    for(0 => int i; i < 25; i++){
        (25 - i) $ float / 40 => n.gain;
        20::ms => now;
    }
    0 => n.gain;
}

fun void melody(int note, int oct, int timbre){
    TriOsc s => LPF sfilt => JCRev srev => Pan2 span => dac;
    Math.random2f(-0.6, 0.6) => span.pan;
    0.1 => srev.mix;
    timbre * 3 + 300 => sfilt.freq;
    5 => sfilt.Q;
    if(chordPullFlag == 0 || (chordPullFlag == 1 && Math.randomf() > 0.93)){
        [-1, 0, 2, 4, 5, 7, 9, 11, 12, 14, 16] @=> int major[];
        Math.random2f(-1.0, 1.0) + Std.mtof(key + major[note % 11]) => s.freq;
    }
    else{
        Math.random2f(-0.5, 0.5) + t[note % 4].freq() * Math.random2(1, 2) => s.freq;
    }
    if(oct > 250){
        s.freq() / 2 => s.freq;
    }
    for(0 => int i; i < 100; i++){
        (100 - i) $ float / 120 => s.gain;
        2::ms => now;
    }
    300::ms => now;
}

fun void changeChords(){
    if(chordQueueStart != chordQueueEnd){
        53 +3 +3 + chordQueue[0][chordQueueStart] => key;
        Std.mtof(chordQueue[1][chordQueueStart] + key) / 4 => bass.freq;
        for(1 => int i; i < 5; i++){
            Math.random2f(-1.0, 1.0) + Std.mtof(chordQueue[i][chordQueueStart] + key) => t[i - 1].freq;
        }
        chordQueue[5][chordQueueStart] => chordPullFlag;
        (chordQueueStart + 1) % queueSize => chordQueueStart;
    }
    if((chordQueueEnd - chordQueueStart) % queueSize < 8){
        xmit.startMsg("/request", "i");
        0 => xmit.addInt; 
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
         [1, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0],
         [1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 1, 0],
         [1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0, 0],
         [1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 1],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]] @=> int bdPats[][];
        Math.random2(4, 8) => int bdPatNum;
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
        if(Math.randomf() > 0.1){
            changeChords();
        }
        if(snareFillFlag == 3){
            0 => snareFillFlag;
            spork ~ cymb();
        }
    }
    if(beat == 8 && Math.randomf() > 0.85){
        changeChords();
    }
    if(beat % 2 == 0){
        10::ms => now;
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
spork ~ chordRecieve();

while(true){
    beat16();
    if(queueStart != queueEnd){
        spork ~ melody(queue[0][queueStart], queue[2][queueStart], queue[1][queueStart]);
        (queueStart + 1) % queueSize => queueStart;
        time16 => now;
        beat16();
        if(queueStart != queueEnd){
            spork ~ melody(queue[0][queueStart], queue[2][queueStart], queue[1][queueStart]);
            (queueStart + 1) % queueSize => queueStart;
        }
    }
    else{
        time16 => now;
        beat16();
    }
    time16 => now;
}
