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
    // A
    "ABACK", "ABATE", "ABBEY", "ABIDE", "ABORT", "ABOUT", "ABOVE", "ABUSE", "ABYSS", "ACORN",
    // B
    "BACON", "BADGE", "BADLY", "BAGEL", "BAKER", "BALMY", "BANJO", "BARGE", "BASIC", "BATCH",
    // C
    "CABLE", "CACHE", "CAMEL", "CANDY", "CAPER", "CARRY", "CATCH", "CAUSE", "CEASE", "CHAIN",
    // D
    "DAILY", "DANCE", "DARED", "DECAY", "DEFER", "DEIGN", "DELVE", "DENIM", "DEPOT", "DEPTH",
    // E
    "EAGER", "EAGLE", "EARLY", "EARTH", "EASEL", "EBONY", "EERIE", "ELBOW", "ELDER", "ELECT",
    // F
    "FABLE", "FACET", "FAINT", "FALSE", "FANCY", "FARGO", "FATAL", "FEAST", "FERAL", "FETCH",
    // G
    "GAUGE", "GAUNT", "GAVEL", "GAZE", "GLEAM", "GLIDE", "GLOAT", "GNASH", "GRACE", "GRAND",
    // H
    "HABIT", "HAIRY", "HAPPY", "HARDY", "HASTE", "HAUNT", "HEART", "HEAVY", "HEDGE", "HEFTY",
    // I
    "IDEAL", "IDIOM", "IDLE", "IMAGE", "IMBUE", "IMPEL", "IMPLY", "INDEX", "INEPT", "INFER",
    // J
    "JAUNT", "JAZZY", "JELLY", "JERKY", "JETTY", "JEWEL", "JOIST", "JOLLY", "JOUST", "JUDGE",
    // K
    "KAYAK", "KEBAB", "KINKY", "KIOSK", "KNACK", "KNEAD", "KNELT", "KNIFE", "KNOCK", "KNOWN",
    // L
    "LABEL", "LABOR", "LANCE", "LANKY", "LAPSE", "LARGE", "LASER", "LATCH", "LATER", "LATHE",
    // M
    "MADAM", "MAGIC", "MAJOR", "MANGO", "MAPLE", "MARCH", "MARRY", "MATCH", "MAUVE", "MAXIM",
    // N
    "NAIVE", "NANNY", "NASAL", "NASTY", "NAVAL", "NEAR", "NEEDY", "NERVE", "NEVER", "NEWLY",
    // O
    "OCCUR", "OCEAN", "OFFER", "OFTEN", "OLIVE", "ONION", "ONSET", "OPERA", "OPINE", "ORBIT",
    // P
    "PADDY", "PAINT", "PALM", "PAPER", "PARTY", "PASTA", "PATCH", "PAUSE", "PEACE", "PEACH",
    // Q
    "QUACK", "QUAIL", "QUAKE", "QUALM", "QUARK", "QUART", "QUEEN", "QUEER", "QUELL", "QUERY",
    // R
    "RADAR", "RADIO", "RAINY", "RAISE", "RALLY", "RAMEN", "RANCH", "RANGE", "RAPID", "RATIO",
    // S
    "SABLE", "SADLY", "SAINT", "SALAD", "SALTY", "SALVE", "SAME", "SANDY", "SANE", "SATIN",
    // T
    "TABLE", "TACIT", "TAKEN", "TALLY", "TALON", "TANGO", "TANGY", "TAPER", "TAPIR", "TARDY",
    // U
    "ULCER", "ULTRA", "UMBRA", "UNCLE", "UNCUT", "UNDER", "UNDUE", "UNFED", "UNIFY", "UNION",
    // V
    "VAGUE", "VAIN", "VALID", "VALOR", "VALUE", "VALVE", "VAPID", "VAULT", "VAUNT", "VEGAN",
    // W
    "WACKY", "WAFER", "WAGER", "WAGON", "WAIST", "WAIVE", "WALTZ", "WARTY", "WASTE", "WATCH",
    // X
    "XENON", "XEROX",
    // Y
    "YACHT", "YEARN", "YEAST", "YIELD", "YOUNG", "YOUTH", "YUMMY",
    // Z
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
