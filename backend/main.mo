import Blob "mo:base/Blob";
import Bool "mo:base/Bool";
import List "mo:base/List";

import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Option "mo:base/Option";
import Random "mo:base/Random";
import Text "mo:base/Text";
import Char "mo:base/Char";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";

actor {
  let WORDS = [
    "ABACK", "ABASE", "ABATE", "ABBEY", "ABBOT", "ABHOR", "ABIDE", "ABLED", "ABODE", "ABORT",
    "ABOUT", "ABOVE", "ABUSE", "ABYSS", "ACORN", "ACRID", "ACTOR", "ACUTE", "ADAGE", "ADAPT",
    "ADEPT", "ADMIN", "ADMIT", "ADOBE", "ADOPT", "ADORE", "ADORN", "ADULT", "AFFIX", "AFIRE",
    "AFOOT", "AFOUL", "AFTER", "AGAIN", "AGAPE", "AGATE", "AGENT", "AGILE", "AGING", "AGLOW",
    "AGONY", "AGREE", "AHEAD", "AIDER", "AISLE", "ALARM", "ALBUM", "ALERT", "ALGAE", "ALIBI",
    "ALIEN", "ALIGN", "ALIKE", "ALIVE", "ALLAY", "ALLEY", "ALLOT", "ALLOW", "ALLOY", "ALOFT",
    "ALONE", "ALONG", "ALOOF", "ALOUD", "ALPHA", "ALTAR", "ALTER", "AMASS", "AMAZE", "AMBER",
    "AMBLE", "AMEND", "AMISS", "AMITY", "AMONG", "AMPLE", "AMPLY", "AMUSE", "ANGEL", "ANGER",
    "ANGLE", "ANGRY", "ANGST", "ANIME", "ANKLE", "ANNEX", "ANNOY", "ANNUL", "ANODE", "ANTIC",
    "ANVIL", "AORTA", "APART", "APHID", "APING", "APNEA", "APPLE", "APPLY", "APRON", "APTLY",
    "ZEBRA", "ZESTY", "ZONAL"
  ];

  stable var currentWord : Text = "";

  public func getRandomWord() : async Text {
    let randomBytes = await Random.blob();
    let randomNumber = Random.rangeFrom(32, randomBytes);
    let index = randomNumber % WORDS.size();
    currentWord := WORDS[index];
    Debug.print("New word set: " # currentWord);
    currentWord
  };

  public query func isValidWord(word : Text) : async Bool {
    Option.isSome(Array.find<Text>(WORDS, func (w) { w == word }))
  };

  public query func evaluateGuess(guess : Text) : async [Text] {
    Debug.print("Evaluating guess: " # guess # " against word: " # currentWord);
    let guessChars = Iter.toArray(Text.toIter(Text.toUppercase(guess)));
    let targetChars = Iter.toArray(Text.toIter(currentWord));
    
    let result = Array.init<Text>(5, "absent");
    var mutableTargetChars = Array.thaw<Char>(targetChars);

    for (i in Iter.range(0, 4)) {
      if (guessChars[i] == targetChars[i]) {
        result[i] := "correct";
        mutableTargetChars[i] := ' ';
      };
    };

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

  public func getWordList() : async [Text] {
    let buffer = Buffer.Buffer<Text>(100);
    let randomBlob = await Random.blob();
    let randomBytes = Random.Finite(randomBlob);
    for (_ in Iter.range(0, 99)) {
      let randomByte = switch (randomBytes.byte()) {
        case null 0;
        case (?b) Nat8.toNat(b);
      };
      let randomIndex = randomByte % WORDS.size();
      buffer.add(WORDS[randomIndex]);
    };
    Buffer.toArray(buffer)
  };
};
