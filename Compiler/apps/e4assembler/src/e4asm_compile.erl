-module(e4asm_compile).
-export([process/2]).

%% @doc Takes: A module map #{} with postprocessed BEAM assembly with new
%%      E4 ASM instructions in it
%% Result: Writes binary e4b file with bytecode.
-spec process(string(), #{}) -> ok.
process(InputPath, Input) ->
  e4asm_stats:init(),  % frequency stats are collected here
  BC = e4c:try_do(
    "e4asm_pass_asm - Assembly to binary",
    fun() -> e4asm_pass_asm:compile(Input) end
  ),
  OutputPath = e4asm_file:make_filename(InputPath, "uerl"),
  save_output(text, BC, OutputPath),
  StatsOutputPath = e4asm_file:make_filename(InputPath, "stats.txt"),
  e4asm_stats:dump(StatsOutputPath).


%% @doc Format the resulting bytecode as text (for debug and simplicity) or
%% as a binary (for final deployment).
save_output(Format, BC, OutputPath) ->
  e4c:try_do("Save " ++ erlang:atom_to_list(Format) ++ " output",
             fun() ->
               IOList = e4asm_file:to_iolist(Format, BC),
               file:write_file(OutputPath, iolist_to_binary(IOList))
             end),
  ok.
