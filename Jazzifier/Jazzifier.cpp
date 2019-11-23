#include <iostream>

using namespace std;

#define SPICE_GEN_RARITY 3
#define MAX_SPICES 2

char noteRandomizer(void);
void randChord(void);
void randChart(int lines, int bars, int chordsPerBar);
void jazzStandard(void);
void blues(int bars, string key);
void printChord(string note, char chordType, int ChordDegree);
unsigned int PRNG(int range);
void printMinorChord(string note);
void printDomChord(string note);
void printMajChord(string note);

//For the jazz chart maker:
//Tritone substitutions
//251 and then 16251, 36251, etc...

int main()
{
    char answer;
    cout << "This application will randomly generate a jazz standard" << endl;
    cout << "First, the application will generate random root notes." << endl;
    cout << "It will then generate the type of chord modifier (7th, o7, ø7, maj7, min7, 9, 13, sus2, sus4) " << endl;
    cout << "The form may range from 12 bars to 32 bars" << endl;
    cout << "You could also specify to create a blues in a certain key." << endl;
    cout << "Note: * means half-diminished" << endl;

    cout << "--------" << endl;
    cout << "Here is the list of commands: " << endl;
    cout << "C - Create a completely random chart!" << endl;
    cout << "J - Create new, randomized jazz standard" << endl;
    cout << "B - Generate a blues" << endl;
    cout << "R - Generate a random chord" << endl;
    cout << "Q - Quit" << endl;
    int bars = 0;
    string key;

    while (answer != 'C' && answer != 'B' && answer != 'R' && answer != 'Q') {
        cout << "" << endl;
        cin >> answer;
        if (answer == 'C' || answer == 'c') {
            randChart(2, 4, 1);
        } else if (answer == 'J' || answer == 'j') {
            cout << "JAZZ: " << endl;
            jazzStandard();
        } else if (answer == 'B' || answer == 'b') {
            cout << "How many bars? (for now, has to be 12 - will change later)" << endl;
            cin >> bars;
            cout << "In what key? (0 for random)" << endl;
            cin >> key;
            blues(bars, key);
        } else if (answer == 'R' || answer == 'r') {
            randChord();
            //cout << randChord() << endl;
        } else if (answer == 'Q' || answer == 'q') {
            cout << "Quitting" << endl;
            break;
        } else {
            cout << "Invalid input" << endl;
        }
    }

    return 0;
}

void randChord() {
    char notes[7] = {'A', 'B', 'C', 'D', 'E', 'F', 'G'};
    char sharpFlat[2] = {'#', 'b'}; //For note, and chord spice modifier
    char chordType[5] = {'m', 'M', '*', 'o', '+'}; //ø = *
    int chordDegree[5] = {6, 7, 9, 11, 13};
    int spiceModifiers[4] = {6, 9, 11, 13};
    int numSpices = 0;
    bool sharpFlatYN = false;
    int tempSpiceMod = -1;
    int prevSpiceMod = -1;

    //Print the note, sharp/flat/none, chordType, chordDegree, then a space and 0-3 spice modifiers (a sharpFlat - and either 6, 9, 11 or 13) - 6 is 13 yah.
    cout << notes[PRNG(7)]; //Gen random note
    sharpFlatYN = PRNG(2); //50-50 chance for having a sharp or flat
    if (sharpFlatYN == 1) {
        cout << sharpFlat[PRNG(2)];
    }
    cout << chordType[PRNG(5)] << chordDegree[PRNG(5)];
    if (PRNG(SPICE_GEN_RARITY) == 0) { //Make it rarer to generate spices
        numSpices = PRNG(MAX_SPICES + 1);
    } else {
        //Leave spices at 0
    }
    if (numSpices > 0) {
        cout << "(";
    }
    for (int i = 0; i < numSpices; i++) {
        sharpFlatYN = PRNG(2); //50-50 chance of having a flat or sharp.
        if (sharpFlatYN == 1) {
            cout << sharpFlat[PRNG(2)];
        }
        tempSpiceMod = spiceModifiers[PRNG(5)];
        while (tempSpiceMod == prevSpiceMod || (tempSpiceMod + prevSpiceMod == 19)) { //If same as last time: OR if a 6 and 13 were generated. (6 is = 13 in jazz)
            tempSpiceMod = spiceModifiers[PRNG(5)]; //Generate another spice.
        }
        cout << tempSpiceMod; //Store as temp. Ensures if another spice is generated, then it can't be the same as the previous.
        if (numSpices > 1 && i < numSpices-1) { //Add commas if on the nth spice (>1) that is also less than the (max#spices - 1).
            cout << ", ";
        }
        prevSpiceMod = tempSpiceMod;
    }
    if (numSpices > 0) { //Only print end bracket if spices.
        cout << ")";
    }

}

void randChart(int lines, int bars, int chordsPerBar) {
    int barNum = 0;
    //Generate 4 bars by 4 lines.
    for (int i = 0; i < lines; i++) { //Number of lines
        for (int j = 0; j < bars; j++) { //Number of bars per line
            barNum++;
            cout << barNum;
            cout << "|";
            for (int k = 0; k < chordsPerBar; k++) { //Chords per bar. (Could also have an option to generate this randomly.
                randChord();
                cout << "\t\t";
            }
        }
        cout << "\n" << endl;
    }
}

void jazzStandard() {
    //Call the randChord function multiple times (until I implement more structure)
    //Randomly generate 25 s.
    string notesFlats[12] = {"A", "Bb", "B", "C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab"};
    string notesSharps[12] = {"A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"};
    int numLines = 0;

    while (numLines < 2) {
        numLines = PRNG(6);
    }
    for (int i = 0; i < numLines; i++) { //The 1625-er
        int keyCentre = PRNG(12);
        int tritoneSub = keyCentre + 1;
        int twochord = keyCentre + 2;
        int v7chord = keyCentre + 7;
        int vichord = keyCentre + 9;
        int root = keyCentre;
        if (v7chord > 11) {
            v7chord -= 12;
        }
        if (vichord > 11) {
            vichord -= 12;
        }
        if (twochord > 11) {
            twochord -= 12;
        }
        if (tritoneSub > 11) {
            tritoneSub -= 12;
        }
        printMajChord(notesFlats[keyCentre]);
        printDomChord(notesFlats[vichord]);
        printMinorChord(notesFlats[twochord]);
        //Potential randomized tritone sub:
        if (PRNG(2) == 1) {
            printDomChord(notesFlats[tritoneSub]);
            //printMajChord(notesFlats[keyCentre]);
        } else {
            printDomChord(notesFlats[v7chord]);
        }
        cout << "" << endl;
    }



}

void printMinorChord(string note) {
    char chordTypes[6] = {'7', 'M', 'm', 'o', '*', '+'};
    int chordDegree[5] = {6, 7, 9, 11, 13};
    int sharpFlat = 0; //0 is flat, 1 is sharp
    printChord(note, chordTypes[2], chordDegree[1]);
}

void printDomChord(string note) {
    char chordTypes[6] = {'7', 'M', 'm', 'o', '*', '+'};
    int chordDegree[5] = {6, 7, 9, 11, 13};
    int sharpFlat = 0; //0 is flat, 1 is sharp
    printChord(note, chordTypes[0], -1);
}

void printMajChord(string note) {
    char chordTypes[6] = {'7', 'M', 'm', 'o', '*', '+'};
    int chordDegree[5] = {6, 7, 9, 11, 13};
    int sharpFlat = 0; //0 is flat, 1 is sharp
    printChord(note, chordTypes[1], chordDegree[1]);
}

void blues(int bars, string key) {
    cout << "Writing a blues in " << key << " with " << bars << " bars!" << endl;

    string notesFlats[12] = {"A", "Bb", "B", "C", "Db", "D", "Eb", "E", "F", "Gb", "G", "Ab"};
    string notesSharps[12] = {"A", "A#", "B", "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#"};
    char chordTypes[6] = {'7', 'M', 'm', 'o', '*', '+'};
    int chordDegree[5] = {6, 7, 9, 11, 13};
    int sharpFlat = 0; //0 is flat, 1 is sharp

    int keyCentre = 0;
    //Note: One whole step is just 2 items away in the array. Will need a mechanism to wrap-around if greater than 12!

    //Find index of key in the arrays! - the key centre
    for (int i = 0; i < 12; i++) {
        //cout << i << " ";
        if (notesFlats[i] == key) {
            sharpFlat = 0;
            keyCentre = i;
        } else if (notesSharps[i] == key) {
            sharpFlat = 1;
            keyCentre = i;
        }
    }

    cout << "KeyCentre is " << keyCentre << endl;

    //Blues form: x4 |I7   x2 |V7  x2 |I7   x1|VI7  x1|V7   x2|I7
    //Assume 4 bars per line.
    int v7chord = keyCentre + 7;
    int vichord = keyCentre + 9;
    int root = keyCentre;
    if (v7chord > 11) {
        v7chord -= 12;
    }
    if (vichord > 11) {
        vichord -= 12;
    }

    for (int i = 0; i < 4; i++) {
        if (sharpFlat == 0) {
            printChord(notesFlats[root], chordTypes[0], -1);
            //cout << notesFlats[keyCentre + 7]; //a 7 chord is 7 semitones away from the root chord at the key centre.
        } else if (sharpFlat == 1) {
            printChord(notesSharps[root], chordTypes[0], -1);
            //cout << notesSharps[keyCentre + 7];
        }

    }
    cout << "" << endl;
    for (int i = 0; i < 2; i++) {
        if (sharpFlat == 0) {
            printChord(notesFlats[v7chord], chordTypes[0], -1);
            //cout << notesFlats[keyCentre + 7]; //a 7 chord is 7 semitones away from the root chord at the key centre.
        } else if (sharpFlat == 1) {
            printChord(notesSharps[v7chord], chordTypes[0], -1);
            //cout << notesSharps[keyCentre + 7];
        }
    }
    for (int i = 0; i < 2; i++) {
        if (sharpFlat == 0) {
            printChord(notesFlats[root], chordTypes[0], -1);
        } else if (sharpFlat == 1) {
            printChord(notesSharps[root], chordTypes[0], -1);
        }

    }
    cout << "" << endl;
    if (sharpFlat == 0) {
        printChord(notesFlats[vichord], chordTypes[0], -1); //+9 gives the IV
    } else if (sharpFlat == 1) {
        printChord(notesSharps[vichord], chordTypes[0], -1);
    }

    if (sharpFlat == 0) {
        printChord(notesFlats[v7chord], chordTypes[0], -1); //+9 gives the IV
    } else if (sharpFlat == 1) {
        printChord(notesSharps[v7chord], chordTypes[0], -1);
    }

    for (int i = 0; i < 2; i++) {
        if (sharpFlat == 0) {
            printChord(notesFlats[root], chordTypes[0], -1);
        } else if (sharpFlat == 1) {
            printChord(notesSharps[root], chordTypes[0], -1);
        }

    }
}

void printChord(string note, char chordType, int chordDegree) {
    cout << "|";
    if (chordDegree == -1) {
        cout << note << chordType;
    } else {
        cout << note << chordType << chordDegree;
    }
    cout << "\t";
}

unsigned int PRNG(int range) { //Generate pesudo-random number
    static unsigned int seed = 5323;
    seed = 8253729 * seed + 2396403;
    return seed % range;
}



