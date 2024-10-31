export const idlFactory = ({ IDL }) => {
  return IDL.Service({
    'evaluateGuess' : IDL.Func([IDL.Text], [IDL.Vec(IDL.Text)], ['query']),
    'getRandomWord' : IDL.Func([], [IDL.Text], []),
  });
};
export const init = ({ IDL }) => { return []; };
