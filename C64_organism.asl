
state("x64sc", "C64 Forever 8.3.7.0")
{
    byte numData : "x64sc.exe", 0x3A8F25;
    byte numCrew : "x64sc.exe", 0x3A8F26;
    byte numPass : "x64sc.exe", 0x3A8F27;
    byte numDisk : "x64sc.exe", 0x3A8F28;
    byte gotoEscape : "x64sc.exe", 0x3A8F2B;
    byte numGun : "x64sc.exe", 0x3A8F2C;
    byte currentDeck : "x64sc.exe", 0x3A8F41;
    byte statusLetter07 : "x64sc.exe", 0x3B85CF;
    byte statusLetter08 : "x64sc.exe", 0x3B85D0;
    byte statusLetter09 : "x64sc.exe", 0x3B85D1;
    byte statusLetter10 : "x64sc.exe", 0x3B85D2;
    uint loaded : "x64sc.exe", 0x3A8F69;
}

state("x64", "C64_Forever_8370")
{
    byte numData : "x64.exe", 0x1899565;
    byte numCrew : "x64.exe", 0x1899566;
    byte numPass : "x64.exe", 0x1899567;
    byte numDisk : "x64.exe", 0x1899568;
    byte gotoEscape : "x64.exe", 0x189956B;
    byte numGun : "x64.exe", 0x189956C;
    byte currentDeck : "x64.exe", 0x1899581;
    byte statusLetter07 : "x64.exe", 0x18A8C0F;
    byte statusLetter08 : "x64.exe", 0x18A8C10;
    byte statusLetter09 : "x64.exe", 0x18A8C11;
    byte statusLetter10 : "x64.exe", 0x18A8C12;
    uint loaded : "x64.exe", 0x18995A9;
}

init {
    // Version identifier
    if (settings["C64_Forever_8370"]) {
		version = "C64 Forever 8.3.7.0";
	}
	else if (settings["Vice64_361"]) {
		version = "Vice 64sc.exe 3.6.1";
	}
    print(version);

    vars.numSplits = 0;
}

startup {
    settings.Add("emulators", true, "Supported Emulators");
    settings.Add("Vice64_361", true, "Vice C64 3.6.1", "emulators");
    settings.Add("C64_Forever_8370", false, "C64 Forever 8.3.7.0", "emulators");
    settings.Add("Data based route", true);
    settings.Add("Debug", false);
}

start {
    if (current.loaded == 2763837926 && current.statusLetter07 != 0 && old.statusLetter07 == 0 ) {
        return true;
    }
}

reset {
    if (current.statusLetter07 == 0 && old.statusLetter07 != 0
        && old.numPass == 0
        && old.numData == 0
        && old.numDisk == 0
        ) {
        vars.numSplits = 0;
        return true;
    }
}

split {
    // Debug info
    if (settings["Debug"]) {
        if (old.currentDeck != current.currentDeck) {
            print(
                "-----------\n" +
                "loaded: " + current.loaded + "\n" +
                "-----------\n" +
                "numSplits: " + vars.numSplits + "\n" +
                "numPass: " + current.numPass + "\n" +
                "numData: " + current.numData + "\n" +
                "numDisk: " + current.numDisk + "\n" +
                "numCrew: " + current.numCrew + "\n" +
                "numGun: " + current.numGun + "\n" +
                "-----------\n" +
                "currentDeck: " + current.currentDeck + "\n" +
                "gotoEscape: " + current.gotoEscape + "\n" +
                "-----------\n" +
                "statusLetter07: " + current.statusLetter07 + "\n" +
                "statusLetter08: " + current.statusLetter08 + "\n" +
                "statusLetter09: " + current.statusLetter09 + "\n" +
                "statusLetter10: " + current.statusLetter10 + "\n" +
                "-----------\n"
            );
        }
    }

    if (settings["Data based route"]) {
        if (old.numData < 18) { // Didn't have all data sets ? (18 = 12 for this value)
            // Just gotten a new data set
            if (current.numData > old.numData) {
                if (settings["Debug"]) {
                    print("got another piece of data [" + current.numData + "] = split!");
                }
                vars.numSplits++;
                return true;
            }
        }
        // Gotten all the data, and just been asked to go to the escape pods
        else if (current.gotoEscape == 1 && old.gotoEscape == 0 ) {
                if (settings["Debug"]) {
                    print("was asked to go to the escape pods [" + current.gotoEscape + "," + old.gotoEscape + "] = split!");
                }
                vars.numSplits++;
                return true;
        // Just gotten the you made it status
        } else if (current.currentDeck == 14
                && current.gotoEscape == 1
                && old.statusLetter07 != 0x0D // M
                && current.statusLetter07 == 0x0D // M
                && current.statusLetter08 == 0x01 // A
                && current.statusLetter09 == 0x04 // D
                && current.statusLetter10 == 0x05 // E
            ) {
                if (settings["Debug"]) {
                    print("status says we made it. well done [" + current.gotoEscape + "," + old.gotoEscape + "] = split!");
                }
                return true;
        }
    } else {
        // Deck E, Arrive at H
        if (vars.numSplits == 0) {
            if (
                current.currentDeck == 7
                && current.numData >= 1
                && current.numPass >= 1
            ) {
                vars.numSplits = 1;
                return true;
            }
        }
        // Deck H - Pass, Arrive at N
        else if (vars.numSplits == 1) {
            if (
                current.currentDeck == 13
                && current.numPass >= 2
            ) {
                vars.numSplits = 2;
                return true;
            }
        }
        // Deck N - Elevator, Arrive at S    
        else if (vars.numSplits == 2) {
            if (
                current.currentDeck == 18
            ) {
                vars.numSplits = 3;
                return true;
            }
        }
        // Deck S - Arrive at P   
        else if (vars.numSplits == 3) {
            if (
                current.currentDeck == 15
                && current.numPass >= 3
                && current.numDisk >= 1
            ) {
                vars.numSplits = 4;
                return true;
            }
        }
        // Deck P - Arrive at N
        else if (vars.numSplits == 4) {
            if (
                current.currentDeck == 13
                && current.numPass >= 1
                && current.numData >= 2
                && current.numDisk >= 1
            ) {
                vars.numSplits = 5;
                return true;
            }
        }
        // Deck N - Arrive at H
        else if (vars.numSplits == 5) {
            if (
                current.currentDeck == 7
                && current.numData >= 2
                && current.numDisk >= 2
            ) {
                vars.numSplits = 6;
                return true;
            }
        }
        // Deck H - Arrive at D
        else if (vars.numSplits == 6) {
            if (
                current.currentDeck == 3
                && current.numData >= 4
                && current.numDisk >= 1
            ) {
                vars.numSplits = 7;
                return true;
            }
        }
        // Deck D - Arrive at O
        else if (vars.numSplits == 7) {
            if (
                current.currentDeck == 14
                && current.numPass >= 1
            ) {
                vars.numSplits = 8;
                return true;
            }
        }
        // Deck O - Arrive at M
        else if (vars.numSplits == 8) {
            if (
                current.currentDeck == 12
                && current.numPass >= 2
            ) {
                vars.numSplits = 9;
                return true;
            }
        }
        // Deck M - Arrive at J
        else if (vars.numSplits == 9) {
            if (
                current.currentDeck == 9
                && current.numPass >= 2
                && current.numData >= 5
            ) {
                vars.numSplits = 10;
                return true;
            }
        }
        // Deck J - Arrive at G
        else if (vars.numSplits == 10) {
            if (
                current.currentDeck == 6
                && current.numPass >= 1
                && current.numData >= 5
                && current.numDisk >= 1
            ) {
                vars.numSplits = 11;
                return true;
            }
        }
        // Deck G - Arrive at D
        else if (vars.numSplits == 11) {
            if (
                current.currentDeck == 3
                && current.numData >= 5
                && current.numDisk >= 2
            ) {
                vars.numSplits = 12;
                return true;
            }
        }
        // Deck D - Arrive at C
        else if (vars.numSplits == 12) {
            if (
                current.currentDeck == 2
                && current.numData >= 6
                && current.numDisk >= 1
            ) {
                vars.numSplits = 13;
                return true;
            }
        }
        // Deck C - Arrive at A
        else if (vars.numSplits == 13) {
            if (
                current.currentDeck == 0
                && current.numPass >= 2
                && current.numData >= 6
                && current.numDisk >= 1
            ) {
                vars.numSplits = 14;
                return true;
            }
        }
        // Deck A - Arrive at C
        else if (vars.numSplits == 14) {
            if (
                current.currentDeck == 2
                && current.numPass >= 2
                && current.numData >= 7
            ) {
                vars.numSplits = 15;
                return true;
            }
        }
        // Deck C - Arrive at D
        else if (vars.numSplits == 15) {
            if (
                current.currentDeck == 3
                && current.numPass >= 2
                && current.numData >= 7
            ) {
                vars.numSplits = 16;
                return true;
            }
        }
        // Deck D - Arrive at I
        else if (vars.numSplits == 16) {
            if (
                current.currentDeck == 8
                && current.numPass >= 2
                && current.numData >= 7
            ) {
                vars.numSplits = 17;
                return true;
            }
        }
        // Deck I - Arrive at L
        else if (vars.numSplits == 17) {
            if (
                current.currentDeck == 11
                && current.numPass >= 3
                && current.numData >= 8
            ) {
                vars.numSplits = 18;
                return true;
            }
        }
        // Deck L - Arrive at O Elevator
        else if (vars.numSplits == 18) {
            if (
                current.currentDeck == 14
                && current.numPass >= 2
                && current.numData >= 9
            ) {
                vars.numSplits = 19;
                return true;
            }
        }
        // Deck O - Arrive at T
        else if (vars.numSplits == 19) {
            if (
                current.currentDeck == 19
                && current.numPass >= 2
                && current.numData >= 9
            ) {
                vars.numSplits = 20;
                return true;
            }
        }
        // Deck T - Arrive at W
        else if (vars.numSplits == 20) {
            if (
                current.currentDeck == 22
                && current.numPass >= 2
                && current.numData >= 9
                && current.numDisk >= 1
            ) {
                vars.numSplits = 21;
                return true;
            }
        }
        // Deck W - Arrive at U
        else if (vars.numSplits == 21) {
            if (
                current.currentDeck == 20
                && current.numPass >= 1
                && current.numData >= 9
                && current.numDisk >= 2
            ) {
                vars.numSplits = 22;
                return true;
            }
        }
        // Deck U - Arrive at F
        else if (vars.numSplits == 22) {
            if (
                current.currentDeck == 5
                && current.numPass >= 1
                && current.numData >= 10
                && current.numDisk >= 1
            ) {
                vars.numSplits = 23;
                return true;
            }
        }
        // Deck F - Arrive at W
        else if (vars.numSplits == 23) {
            if (
                current.currentDeck == 22
                && current.numPass >= 1
                && current.numData >= 11
            ) {
                vars.numSplits = 24;
                return true;
            }
        }
        // Deck W - Arrive at X
        else if (vars.numSplits == 24) {
            if (
                current.currentDeck == 23
                && current.numPass >= 1
                && current.numData >= 11
            ) {
                vars.numSplits = 25;
                return true;
            }
        }
        // Deck X - Boss fight
        else if (vars.numSplits == 25) {
            if (
                current.currentDeck == 23
                && current.numData >= 12
            ) {
                vars.numSplits = 26;
                return true;
            }
        }
        // Boss fight
        else if (vars.numSplits == 26) {
            if (
                current.currentDeck == 23
                && current.gotoEscape == 1
            ) {
                vars.numSplits = 27;
                return true;
            }
        }
        // Made it
        else if (vars.numSplits == 27) {
            if (
                current.currentDeck == 14
                && current.gotoEscape == 1
                && current.statusLetter07 == 0x0D // M
                && current.statusLetter08 == 0x01 // A
                && current.statusLetter09 == 0x04 // D
                && current.statusLetter10 == 0x05 // E
            ) {
                vars.numSplits = 27;
                return true;
            }
        }
    }
}

update {
    if (version == "") {
	    return false;
    }
}
