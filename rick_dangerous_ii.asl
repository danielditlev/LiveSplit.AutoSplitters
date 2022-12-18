state("x64sc", "Vice64_361") {
    // lives                : 7FF7DF5F8F49 : 3A8F49
    byte numLives :  "x64sc.exe", 0x3A8F49;
    byte numTnt :    "x64sc.exe", 0x3A8F4A;
    byte numAmmo :   "x64sc.exe", 0x3A8F4B;

    byte highOne :   "x64sc.exe", 0x3A8F4C;
    byte highTwo :   "x64sc.exe", 0x3A8F4D;
    byte highThree : "x64sc.exe", 0x3A8F4E;

    byte startingLevel : "x64sc.exe", 0x3A994A;
    byte levelTimer :    "x64sc.exe", 0x3AADB2;
    byte levelStarted :  "x64sc.exe", 0x3AADE8;
    byte theEnd :        "x64sc.exe", 0x3AE0DA;
    byte currentLevel :  "x64sc.exe", 0x3B0C04;

    // [H]YDE PARK          : 7FF7DF605029 : 3B5029 | 48 59 44 45 20 50 41 52 4B
    byte textHyde1 : "x64sc.exe", 0x3B5029;
    byte textHyde2 : "x64sc.exe", 0x3B502A;
    byte textHyde3 : "x64sc.exe", 0x3B502B;
    byte textHyde4 : "x64sc.exe", 0x3B502C;

    // [P]RESS FIRE TO PLAY : 7FF7DF605283 : 3B5283 | 50 52 45 53 53 20 46 49 52 45 20 54 4F 20 54 4F 20 50 4C 41 59 
    byte textPress1 : "x64sc.exe", 0x3B5283;
    byte textPress2 : "x64sc.exe", 0x3B5284;
    byte textPress3 : "x64sc.exe", 0x3B5285;
    byte textPress4 : "x64sc.exe", 0x3B5286;
}

init {
    // Version identifier
	if (settings["Vice64_361"]) {
		version = "Vice 64sc.exe 3.6.1";
	}
    
    if (settings["Debug"]) {
        print("Version: " + version + "\n");
    }

    vars.numSplits = 0;
    vars.hasLoaded = false;
    vars.human = false;
    vars.hydePark = false;

    vars.stateStart = false;
    vars.stateStartWhy = "";
    vars.stateReset = false;
    vars.stateResetWhy = "";
    vars.stateSplit = false;
    vars.stateSplitWhy = "";
    vars.stateCompleted = false;
    vars.stateCompletedWhy = "";
}

startup {
    settings.Add("emulators", true, "Supported Emulators");
    settings.Add("Vice64_361", true, "Vice C64 3.6.1", "emulators");
    settings.Add("IsLoading", false);
    settings.Add("Debug", false);
}

start {
    vars.stateStart = false;
    vars.stateStartWhy = "";

    // Check for [Hyde] park (level selection menu) 
    // So when can differentiate between demo start and a human starting
    if (
        vars.human == false &&
        current.textHyde1 == 0x48 &&
        current.textHyde2 == 0x59 &&
        current.textHyde3 == 0x44 &&
        current.textHyde4 == 0x45
    ) {
        if (settings["Debug"]) {
            print( "[HYDE] PARK showing -----------\n");
        }
        vars.human = true;
        vars.hydePark = true;
    }

    // Check if the level selection menu has just disappeared.
    if (settings["IsLoading"] == false) {
        if (
            vars.hydePark == true &&
            current.textHyde1 != 0x48 &&
            current.textHyde2 != 0x59 &&
            current.textHyde3 != 0x44 &&
            current.textHyde4 != 0x45
        ) {
            vars.stateStart = true;
            vars.stateStartWhy = "Hyde Park";
        }
    }

    // Start based on level timer 
    if (vars.human == true && // Don't start in demo mode
        vars.numSplits == 0 && current.levelStarted == 1 && current.levelTimer != old.levelTimer) {

        vars.stateStart = true;
        vars.stateStartWhy = "Level Timer";
    }

    if (vars.stateStart == true) {
        if (settings["Debug"]) {
            print( "START [" + vars.stateStartWhy + "]-----------\n" +
                "numSplits: " + vars.numSplits + "\n" +
                "startingLevel: " + current.startingLevel + "\n" +
                "levelTimer: " + current.levelTimer + "\n" +
                "levelStarted: " + current.levelStarted + "\n" +
                "theEnd: " + current.theEnd + "\n" +
                "currentLevel: " + current.currentLevel + "\n" +
                "-----------\n" +
                "highOne: " + current.highOne + "\n" +
                "highTwo: " + current.highTwo + "\n" +
                "highThree: " + current.highThree + "\n" +
                "-----------\n" +
                "numAmmo: " + current.numAmmo + "\n" +
                "numTnt: " + current.numTnt + "\n" +
                "numLives: " + current.numLives + "\n" +
                "-----------\n"
            );
        }

        vars.numSplits = 1;
        vars.hasLoaded = false;
        vars.hydePark = false;

        vars.stateCompleted = false;
        return true;
    }
}

reset {
    vars.stateReset = false;
    vars.stateResetWhy = "";

    if (
        vars.stateCompleted == false && // Don't reset if we have just completed the game
        (current.textPress1 == 0x50 && // Fallback in case of snapshot reset
        current.textPress2 == 0x52 &&  // Check for [Pres]s fire to play
        current.textPress3 == 0x45 &&
        current.textPress4 == 0x53)
    ) {
        if (settings["Debug"]) {
            print( "[PRES]S FIRE TO PLAY -----------\n");
        }
        vars.stateReset = true;
        vars.stateResetWhy = "Title screen";
    }

    if (vars.stateReset == true) {
        if (settings["Debug"]) {
            print( "RESET [" + vars.stateResetWhy + "]-----------\n" +
                "numSplits: " + vars.numSplits + "\n" +
                "startingLevel: " + current.startingLevel + "\n" +
                "levelTimer: " + current.levelTimer + "\n" +
                "levelStarted: " + current.levelStarted + "\n" +
                "theEnd: " + current.theEnd + "\n" +
                "currentLevel: " + current.currentLevel + "\n" +
                "-----------\n" +
                "highOne: " + current.highOne + "\n" +
                "highTwo: " + current.highTwo + "\n" +
                "highThree: " + current.highThree + "\n" +
                "-----------\n" +
                "numAmmo: " + current.numAmmo + "\n" +
                "numTnt: " + current.numTnt + "\n" +
                "numLives: " + current.numLives + "\n" +
                "-----------\n"
            );
        }

        vars.human = false;
        vars.numSplits = 0;
        vars.hasLoaded = false;
        vars.stateCompleted = false;
        
        return true;
    }
}

split {
    vars.stateSplit = false;
    vars.stateSplitWhy = "";

    // Level 1 = 1 // Hyde Park
    // Level 2 = 2 // Ice Caverns
    // Level 3 = 3 // Forests
    // Level 4 = 4 // Mines
    // Level 5 = 5 // HQ

    if (vars.numSplits > 0 && current.currentLevel != old.currentLevel ) {
        vars.numSplits++;

        vars.stateSplit = true;
        vars.stateSplitWhy = "Level changed";
    }

    if (vars.stateCompleted == false && current.currentLevel == 5) {
        if (current.theEnd == 1 ) {
            if (settings["Debug"]) {
                print( "COMPLETED [theEnd]-----------\n");
            }

            vars.stateCompleted = true;
            vars.stateCompletedWhy = "theEnd byte was set";

            vars.stateSplit = true;
            vars.stateSplitWhy = vars.stateCompletedWhy;

        } else if (current.highThree == old.highThree + 0x10 && current.numLives == old.numLives - 1) {
            if (settings["Debug"]) {
                print( "COMPLETED [livesTrade]-----------\n");
            }
            vars.stateCompleted = true;
            vars.stateCompletedWhy = "lives trading";

            vars.stateSplit = true;
            vars.stateSplitWhy = vars.stateCompletedWhy;
        }
    }

    if (vars.stateSplit == true) {
        if (settings["Debug"]) {
            print( "SPLIT [" + vars.stateSplitWhy + "]-----------\n" +
                "numSplits: " + vars.numSplits + "\n" +
                "startingLevel: " + current.startingLevel + "\n" +
                "levelTimer: " + current.levelTimer + "\n" +
                "levelStarted: " + current.levelStarted + "\n" +
                "theEnd: " + current.theEnd + "\n" +
                "currentLevel: " + current.currentLevel + "\n" +
                "-----------\n" +
                "highOne: " + current.highOne + "\n" +
                "highTwo: " + current.highTwo + "\n" +
                "highThree: " + current.highThree + "\n" +
                "-----------\n" +
                "numAmmo: " + current.numAmmo + "\n" +
                "numTnt: " + current.numTnt + "\n" +
                "numLives: " + current.numLives + "\n" +
                "-----------\n"
            );
        }

        vars.numSplits++;
        return true;
    }
}

isLoading {
    if (settings["IsLoading"]) {
        if (vars.numSplits > 0 && current.currentLevel != old.currentLevel && vars.hasLoaded) {
            if (settings["Debug"]) {
                print( "IS LOADING -----------\n");
            }
            vars.hasLoaded = false;
        }

        if (vars.hasLoaded == false && current.levelTimer != old.levelTimer) {
            if (settings["Debug"]) {
                print( "HAS LOADED -----------\n");
            }
            vars.hasLoaded = true;
        }

        return (vars.hasLoaded == false);
    }
}

update {
    if (version == "") {
	    return false;
    }
}
