%%%============================================================================
%%%     Core Forth definitions
%%%
%%%     Core Erlang very approximately maps to Core Forth with some
%%%     simplifications and generalizations on the way
%%%============================================================================
-ifndef(E4_CORE_FORTH).
-define(E4_CORE_FORTH, 1).

-record(cf_var, {name :: atom()}).
-type cf_var() :: #cf_var{}.

%%-record(cf_funarity, {fn :: atom(), arity :: integer()}).

-record(cf_mfarity, {mod :: atom(), fn :: atom(), arity :: integer()}).
-type cf_mfarity() :: #cf_mfarity{}.

-record(cf_lit, {val :: any()}).
-type cf_lit() :: #cf_lit{}.

-record(cf_comment, {comment :: any()}).
-type cf_comment() :: #cf_comment{}.

%% A code block with prefix and suffix
%% TODO: Have var scopes merged with this? Not sure how to find scope parent
-record(cf_block, {
    before=[] :: cf_code(),
    %% A copy of upper level scope + own variables
    scope=[] :: [cf_var()],
    code=[] :: cf_code(), % forth program output
    'after'=[] :: cf_code()
}).
-type cf_block() :: #cf_block{}.

-type cf_word() :: atom().
-type cf_op() :: cf_word() | cf_comment() | cf_lit() | cf_block()
                | cf_mfarity() | cf_new_var() | cf_new_arg()
                | cf_retrieve() | cf_store().
-type cf_code() :: [cf_op() | cf_code()].

%% TODO: not sure if used in this pass
-record(cf_mod, {
    module=undefined,
    atom_counter=0,
    atoms=dict:new(),
    lit_counter=0,
    literals=dict:new(),
    %% list of nested code blocks, containing code
    code=[] :: cf_code()
%%    %% Compile-time state
%%    stack=[] :: [e4var()]
}).

%%-type cf_mod() :: #cf_mod{}.

%% Marking for variable operation, either read or write
-record(cf_retrieve, {var :: cf_var()}).
-record(cf_store, {var :: cf_var()}).
-type cf_retrieve() :: #cf_retrieve{}.
-type cf_store() :: #cf_store{}.

-record(cf_stack_top, {}). % denotes the value currently on the stack top
-type cf_stack_top() :: #cf_stack_top{}.

-record(cf_apply, {funobj, args=[]}).

%% introduce a new variable (produces no code, but allocates storage in a
%% further pass)
-record(cf_new_var, {var :: cf_var()}).
-type cf_new_var() :: #cf_new_var{}.

%% introduce a new variable which is already on stack, and should not have
%% storage allocated.
-record(cf_new_arg, {var :: cf_var()}).
-type cf_new_arg() :: #cf_new_arg{}.

%% introduce a new name to existing variable (produces no code)
-record(cf_alias, {var :: cf_var(), existing :: cf_var()}).

-endif.
