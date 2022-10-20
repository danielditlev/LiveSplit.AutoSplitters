
state("x64sc", "Vice64_361")
{
    byte numData : "x64sc.exe", 0x3A8F25;
    byte numCrew : "x64sc.exe", 0x3A8F26;
    byte numPass : "x64sc.exe", 0x3A8F27;
    byte numDisk : "x64sc.exe", 0x3A8F28;
    byte gotoEscape : "x64sc.exe", 0x3A8F2B;
    byte numGun : "x64sc.exe", 0x3A8F2C;
    byte currentDeck : "x64sc.exe", 0x3A8F41;
    byte statusLetter01 : "x64sc.exe", 0x3B85C9;
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
    byte statusLetter01 : "x64.exe", 0x18A8C09;
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
    settings.Add("Debug", false);
}

start {
    if (current.loaded == 2763837926 && current.statusLetter01 != 0 && old.statusLetter01 == 0 ) {
        return true;
    }
}

reset {
    if (current.statusLetter01 == 0 && old.statusLetter01 != 0
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
                "statusLetter01: " + current.statusLetter01 + "\n" +
                "statusLetter07: " + current.statusLetter07 + "\n" +
                "statusLetter08: " + current.statusLetter08 + "\n" +
                "statusLetter09: " + current.statusLetter09 + "\n" +
                "statusLetter10: " + current.statusLetter10 + "\n" +
                "-----------\n"
            );
        }
    }

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
}

update {
    if (version == "") {
	    return false;
    }
}
