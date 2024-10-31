import Array "mo:base/Array";
import Iter "mo:base/Iter";
import Random "mo:base/Random";
import Text "mo:base/Text";
import Char "mo:base/Char";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Nat8 "mo:base/Nat8";

actor {
  let WORDS = [
    "ABACK", "ABATE", "ABBEY", "ABIDE", "ABORT", "ABOUT", "ABOVE", "ABUSE", "ABYSS", "ACORN",
    "BACON", "BADGE", "BADLY", "BAGEL", "BAKER", "BALMY", "BANJO", "BARGE", "BASIC", "BATCH",
    "CABLE", "CACHE", "CAMEL", "CANDY", "CAPER", "CARRY", "CATCH", "CAUSE", "CEASE", "CHAIN",
    "DAILY", "DANCE", "DARED", "DECAY", "DEFER", "DEIGN", "DELVE", "DENIM", "DEPOT", "DEPTH",
    "EAGER", "EAGLE", "EARLY", "EARTH", "EASEL", "EBONY", "EERIE", "ELBOW", "ELDER", "ELECT",
    "FABLE", "FACET", "FAINT", "FALSE", "FANCY", "FARGO", "FATAL", "FEAST", "FERAL", "FETCH",
    "GAUGE", "GAUNT", "GAVEL", "GAZE", "GLEAM", "GLIDE", "GLOAT", "GNASH", "GRACE", "GRAND",
    "HABIT", "HAIRY", "HAPPY", "HARDY", "HASTE", "HAUNT", "HEART", "HEAVY", "HEDGE", "HEFTY",
    "IDEAL", "IDIOM", "IDLE", "IMAGE", "IMBUE", "IMPEL", "IMPLY", "INDEX", "INEPT", "INFER",
    "JAUNT", "JAZZY", "JELLY", "JERKY", "JETTY", "JEWEL", "JOIST", "JOLLY", "JOUST", "JUDGE",
    "KAYAK", "KEBAB", "KINKY", "KIOSK", "KNACK", "KNEAD", "KNELT", "KNIFE", "KNOCK", "KNOWN",
    "LABEL", "LABOR", "LANCE", "LANKY", "LAPSE", "LARGE", "LASER", "LATCH", "LATER", "LATHE",
    "MADAM", "MAGIC", "MAJOR", "MANGO", "MAPLE", "MARCH", "MARRY", "MATCH", "MAUVE", "MAXIM",
    "NAIVE", "NANNY", "NASAL", "NASTY", "NAVAL", "NEAR", "NEEDY", "NERVE", "NEVER", "NEWLY",
    "OCCUR", "OCEAN", "OFFER", "OFTEN", "OLIVE", "ONION", "ONSET", "OPERA", "OPINE", "ORBIT",
    "PADDY", "PAINT", "PALM", "PAPER", "PARTY", "PASTA", "PATCH", "PAUSE", "PEACE", "PEACH",
    "QUACK", "QUAIL", "QUAKE", "QUALM", "QUARK", "QUART", "QUEEN", "QUEER", "QUELL", "QUERY",
    "RADAR", "RADIO", "RAINY", "RAISE", "RALLY", "RAMEN", "RANCH", "RANGE", "RAPID", "RATIO",
    "SABLE", "SADLY", "SAINT", "SALAD", "SALTY", "SALVE", "SAME", "SANDY", "SANE", "SATIN",
    "TABLE", "TACIT", "TAKEN", "TALLY", "TALON", "TANGO", "TANGY", "TAPER", "TAPIR", "TARDY",
    "ULCER", "ULTRA", "UMBRA", "UNCLE", "UNCUT", "UNDER", "UNDUE", "UNFED", "UNIFY", "UNION",
    "VAGUE", "VAIN", "VALID", "VALOR", "VALUE", "VALVE", "VAPID", "VAULT", "VAUNT", "VEGAN",
    "WACKY", "WAFER", "WAGER", "WAGON", "WAIST", "WAIVE", "WALTZ", "WARTY", "WASTE", "WATCH",
    "XENON", "XEROX",
    "YACHT", "YEARN", "YEAST", "YIELD", "YOUNG", "YOUTH", "YUMMY",
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

  public query func evaluateGuess(guess : Text) : async [Text] {
    Debug.print("Evaluating guess: " # guess # " against word: " # currentWord);
    let guessChars = Iter.toArray(Text.toIter(Text.toUppercase(guess)));
    let targetChars = Iter.toArray(Text.toIter(currentWord));
    
    if (guessChars.size() != 5) {
      return ["invalid"];
    };

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
};
