OscSend xmit;
xmit.setHost("localhost", 9433);

while(true){
    xmit.startMsg("/collision", "i i i i i i i i");
    Math.random2(200, 1000) => xmit.addInt;
    for(0 => int i; i < 7; i++){
        1 => xmit.addInt;
    }
    Math.random2(10, 1000)::ms => now;
}
