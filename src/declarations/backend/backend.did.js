export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'evaluateGuess' : IDL.Func([IDL.Text], [IDL.Vec(IDL.Text)], ['query']),
    'getRandomWord' : IDL.Func([], [IDL.Text], []),
    'getWordList' : IDL.Func([], [IDL.Vec(IDL.Text)], []),
    'isValidWord' : IDL.Func([IDL.Text], [IDL.Bool], ['query']),
  });
};
export const init = ({ IDL }) => { return []; };
