state("x64sc", "Vice64_361")
{
    byte highOne : "x64sc.exe", 0x3A8F22;
    byte highTwo : "x64sc.exe", 0x3A8F23;
    byte highThree : "x64sc.exe", 0x3A8F24;

    byte numAmmoShown : "x64sc.exe", 0x3ABC0F;
    byte numTntShown : "x64sc.exe", 0x3ABC10;
    byte numLivesShown : "x64sc.exe", 0x3ABC11;
    byte numAmmo : "x64sc.exe", 0x3ABC12;
    byte numTnt : "x64sc.exe", 0x3ABC13;
    byte numLives : "x64sc.exe", 0x3ABC14;
    byte levelTimer : "x64sc.exe", 0x3ABC15;
    byte levelStarted : "x64sc.exe", 0x3AC7C0;
    byte currentLevel : "x64sc.exe", 0x3B74AC;
}

/*
state("x64", "C64_Forever_8370")
{
    byte highOne : "x64sc.exe", 0x3A8F22;
    byte highTwo : "x64sc.exe", 0x3A8F23;
    byte highThree : "x64sc.exe", 0x3A8F24;

    byte numAmmoShown : "x64sc.exe", 0x3ABC0F;
    byte numTntShown : "x64sc.exe", 0x3ABC10;
    byte numLivesShown : "x64sc.exe", 0x3ABC11;
    byte numAmmo : "x64sc.exe", 0x3ABC12;
    byte numTnt : "x64sc.exe", 0x3ABC13;
    byte numLives : "x64sc.exe", 0x3ABC14;
    byte levelTimer : "x64sc.exe", 0x3ABC15;
    byte levelStarted : "x64sc.exe", 0x3AC7C0;
    byte currentLevel : "x64sc.exe", 0x3B74AC;
}
*/

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
    vars.hasLoaded = false;
    vars.completed = false;
}

startup {
    settings.Add("emulators", true, "Supported Emulators");
    settings.Add("Vice64_361", true, "Vice C64 3.6.1", "emulators");
    //settings.Add("C64_Forever_8370", false, "C64 Forever 8.3.7.0", "emulators");
    settings.Add("Debug", false);
}

start {
    // Start when 
    if (old.levelTimer != current.levelTimer && vars.numSplits == 0 ) {
        vars.numSplits = 1;
        vars.hasLoaded = false;
        vars.completed = false;

        if (settings["Debug"]) {
            print( "START -----------\n" +
                "numSplits: " + vars.numSplits + "\n" +
                "levelTimer: " + current.levelTimer + "\n" +
                "levelStarted: " + current.levelStarted + "\n" +
                "currentLevel: " + current.currentLevel + "\n" +
                "-----------\n" +
                "numAmmoShown: " + current.numAmmoShown + "\n" +
                "numTntShown: " + current.numTntShown + "\n" +
                "numLivesShown: " + current.numLivesShown + "\n" +
                "-----------\n" +
                "numAmmo: " + current.numAmmo + "\n" +
                "numTnt: " + current.numTnt + "\n" +
                "numLives: " + current.numLives + "\n" +
                "-----------\n"
            );
        }

        return true;
    }
}

reset {
    if (vars.completed == false // Don't reset if we have just completed the game
        && (current.highOne == 0
        && current.highTwo == 0
        && current.highThree == 0
        && current.numAmmoShown == 0 && current.numTntShown == 0 && current.numLivesShown == 0) || current.numLives == 0
    ) {
        if (settings["Debug"]) {
            print( "RESET -----------\n" +
                "numSplits: " + vars.numSplits + "\n" +
                "levelTimer: " + current.levelTimer + "\n" +
                "levelStarted: " + current.levelStarted + "\n" +
                "currentLevel: " + current.currentLevel + "\n" +
                "-----------\n" +
                "numAmmoShown: " + current.numAmmoShown + "\n" +
                "numTntShown: " + current.numTntShown + "\n" +
                "numLivesShown: " + current.numLivesShown + "\n" +
                "-----------\n" +
                "numAmmo: " + current.numAmmo + "\n" +
                "numTnt: " + current.numTnt + "\n" +
                "numLives: " + current.numLives + "\n" +
                "-----------\n"
            );
        }

        vars.numSplits = 0;
        vars.hasLoaded = false;
        return true;
    }
}

split {
    // Level 1 = 1 // Amazon
    // Level 2 = 2 // Egypt
    // Level 3 = 6 // Castle
    // Level 4 = 9 // Base
    // Level 5 = 64 // Completed

    if (vars.numSplits > 0 && current.currentLevel != old.currentLevel ) {
        if (settings["Debug"]) {
            print( "SPLIT -----------\n" +
                "numSplits: " + vars.numSplits + "\n" +
                "levelTimer: " + current.levelTimer + "\n" +
                "levelStarted: " + current.levelStarted + "\n" +
                "currentLevel: " + current.currentLevel + "\n" +
                "-----------\n" +
                "numAmmoShown: " + current.numAmmoShown + "\n" +
                "numTntShown: " + current.numTntShown + "\n" +
                "numLivesShown: " + current.numLivesShown + "\n" +
                "-----------\n" +
                "numAmmo: " + current.numAmmo + "\n" +
                "numTnt: " + current.numTnt + "\n" +
                "numLives: " + current.numLives + "\n" +
                "-----------\n"
            );
        }

        if (current.currentLevel == 64) {
            vars.completed = true;
        }

        return true;
    }

    if (settings["Debug"]) {
        if (current.numAmmo != old.numAmmo ||
            current.numTnt != old.numTnt ||
            current.numLives != old.numLives) {
            print( "DEBUG -----------\n" +
                "numSplits: " + vars.numSplits + "\n" +
                "levelTimer: " + current.levelTimer + "\n" +
                "levelStarted: " + current.levelStarted + "\n" +
                "currentLevel: " + current.currentLevel + "\n" +
                "-----------\n" +
                "numAmmoShown: " + current.numAmmoShown + "\n" +
                "numTntShown: " + current.numTntShown + "\n" +
                "numLivesShown: " + current.numLivesShown + "\n" +
                "-----------\n" +
                "numAmmo: " + current.numAmmo + "\n" +
                "numTnt: " + current.numTnt + "\n" +
                "numLives: " + current.numLives + "\n" +
                "-----------\n"
            );
        }
    }
}

isLoading {
    if (vars.numSplits > 0 && current.currentLevel != old.currentLevel ) {
        vars.hasLoaded = false;
    }

    if (vars.hasLoaded == false && current.levelTimer != old.levelTimer) {
        vars.hasLoaded = true;
    }

    return (vars.hasLoaded == false);
}

update {
    if (version == "") {
	    return false;
    }
}
