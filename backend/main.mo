import Bool "mo:base/Bool";
import Func "mo:base/Func";

import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Random "mo:base/Random";
import Text "mo:base/Text";
import Char "mo:base/Char";
import Debug "mo:base/Debug";

actor {
  // Word list
  let WORDS = [
    "ABOUT", "ABOVE", "ABUSE", "ACTOR", "ACUTE", "ADMIT", "ADOPT", "ADULT", "AFTER", "AGAIN",
    "AGENT", "AGREE", "AHEAD", "ALARM", "ALBUM", "ALERT", "ALIKE", "ALIVE", "ALLOW", "ALONE",
    "ALONG", "ALTER", "AMONG", "ANGER", "ANGLE", "ANGRY", "APART", "APPLE", "APPLY", "ARENA",
    "ARGUE", "ARISE", "ARRAY", "ASIDE", "ASSET", "AUDIO", "AUDIT", "AVOID", "AWARD", "AWARE",
    "BADLY", "BAKER", "BASES", "BASIC", "BASIS", "BEACH", "BEGAN", "BEGIN", "BEGUN", "BEING",
    "BELOW", "BENCH", "BILLY", "BIRTH", "BLACK", "BLAME", "BLIND", "BLOCK", "BLOOD", "BOARD",
    "BOOST", "BOOTH", "BOUND", "BRAIN", "BRAND", "BREAD", "BREAK", "BREED", "BRIEF"
  ];

  stable var currentWord : Text = "";

  // Function to get a random word
  public func getRandomWord() : async Text {
    let randomBytes = await Random.blob();
    let randomNumber = Random.rangeFrom(32, randomBytes);
    let index = randomNumber % WORDS.size();
    currentWord := WORDS[index];
    Debug.print("New word set: " # currentWord);
    currentWord
  };

  // Function to check if a word is valid
  public func isValidWord(word : Text) : async Bool {
    Option.isSome(Array.find<Text>(WORDS, func (w) { w == word }))
  };

  // Function to evaluate a guess
  public func evaluateGuess(guess : Text) : async [Text] {
    Debug.print("Evaluating guess: " # guess # " against word: " # currentWord);
    let guessChars = Iter.toArray(Text.toIter(Text.toUppercase(guess)));
    let targetChars = Iter.toArray(Text.toIter(currentWord));
    
    let result = Array.init<Text>(5, "absent");
    var mutableTargetChars = Array.thaw<Char>(targetChars);

    // First pass: mark correct letters
    for (i in Iter.range(0, 4)) {
      if (guessChars[i] == targetChars[i]) {
        result[i] := "correct";
        mutableTargetChars[i] := ' ';
      };
    };

    // Second pass: mark present letters
    for (i in Iter.range(0, 4)) {
      if (result[i] == "absent") {
        switch (Array.indexOf<Char>(guessChars[i], Array.freeze(mutableTargetChars), Char.equal)) {
          case (?index) {
            result[i] := "present";
            mutableTargetChars[index] := ' ';
          };
          case null {};
        };
      };
    };

    Debug.print("Evaluation result: " # debug_show(Iter.toArray(result.vals())));
    Iter.toArray(result.vals())
  };
};
