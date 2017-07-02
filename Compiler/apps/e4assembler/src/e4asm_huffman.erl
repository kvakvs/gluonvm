%%% @doc Given a list of integers (the program) figure out Huffman encoding
%%% for this program and the decoding tree.
%%% @end

-module(e4asm_huffman).

-export([encode_funs/1, decode/2, main/1]).

%% @doc Given the module (for labels) and list of compiled funs with operators
%% {Opcode, Arg} produce frequency tree and encode each fun separately.
encode_funs(#{'$' := e4mod, funs := Funs}) ->
  lists:map(fun encode_one_fun/1, Funs).


encode(Text) ->
  Tree = tree(freq_table(Text)),
  Dict = dict:from_list(codewords(Tree)),
  Code = <<<<(dict:fetch(Char, Dict))/bitstring>> || Char <- Text>>,
  #{'$' => huffman,
    code => Code,
    tree => Tree,
    dict => Dict}.


decode(Code, Tree) ->
  decode(Code, Tree, Tree, []).


main(Input) ->
  {Code, Tree, Dict} = encode(Input),
  [begin
     io:format("~s: ", [[Key]]),
     print_bits(Value)
   end || {Key, Value} <- lists:sort(dict:to_list(Dict))],
  io:format("encoded: "),
  print_bits(Code),
  io:format("decoded: "),
  io:format("~s\n", [decode(Code, Tree)]).


decode(<<>>, _, _, Result) ->
  lists:reverse(Result);

decode(<<0:1, Rest/bits>>, Tree, {L = {_, _}, _R}, Result) ->
  decode(<<Rest/bits>>, Tree, L, Result);

decode(<<0:1, Rest/bits>>, Tree, {L, _R}, Result) ->
  decode(<<Rest/bits>>, Tree, Tree, [L | Result]);

decode(<<1:1, Rest/bits>>, Tree, {_L, R = {_, _}}, Result) ->
  decode(<<Rest/bits>>, Tree, R, Result);

decode(<<1:1, Rest/bits>>, Tree, {_L, R}, Result) ->
  decode(<<Rest/bits>>, Tree, Tree, [R | Result]).


codewords({L, R}) ->
  codewords(L, <<0:1>>) ++ codewords(R, <<1:1>>).


codewords({L, R}, <<Bits/bits>>) ->
  codewords(L, <<Bits/bits, 0:1>>) ++ codewords(R, <<Bits/bits, 1:1>>);

codewords(Symbol, <<Bits/bitstring>>) ->
  [{Symbol, Bits}].


tree([{N, _} | []]) ->
  N;

tree(Ns) ->
  [{N1, C1}, {N2, C2} | Rest] = lists:keysort(2, Ns),
  tree([{{N1, N2}, C1 + C2} | Rest]).


freq_table(Text) ->
  freq_table(lists:sort(Text), []).


freq_table([], Acc) ->
  Acc;

freq_table([S | Rest], Acc) ->
  {Block, MoreBlocks} = lists:splitwith(fun(X) -> X == S end, Rest),
  freq_table(MoreBlocks, [{S, 1 + length(Block)} | Acc]).


print_bits(<<>>) ->
  io:format("\n");

print_bits(<<Bit:1, Rest/bitstring>>) ->
  io:format("~w", [Bit]),
  print_bits(Rest).
