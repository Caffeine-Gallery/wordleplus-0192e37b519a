export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'evaluateGuess' : IDL.Func([IDL.Text], [IDL.Vec(IDL.Text)], []),
    'getRandomWord' : IDL.Func([], [IDL.Text], []),
    'isValidWord' : IDL.Func([IDL.Text], [IDL.Bool], []),
  });
};
export const init = ({ IDL }) => { return []; };
