OscSend xmit;
xmit.setHost("localhost", 6449);

while(true){
    xmit.startMsg("/note/length/distance", "i i i");
    Math.random2(200, 1000) => xmit.addInt;
    1 => xmit.addInt;
    1 => xmit.addInt;
    Math.random2(10, 1000)::ms => now;
}
