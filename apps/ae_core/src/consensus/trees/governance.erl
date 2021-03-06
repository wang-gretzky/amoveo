-module(governance).
-export([det_power/3,tree_number_to_value/1, max/0,
	 is_locked/1, change/3, genesis_state/0,
	 get/2, write/2, %lock/2, unlock/2,
	 get_value/2, serialize/1, name2number/1,
	 verify_proof/4, root_hash/1, dict_get/2,
         dict_get_value/2, dict_lock/2, dict_unlock/2,
         make_leaf/3, key_to_int/1, deserialize/1,
         dict_write/2,
	 test/0]).
-record(gov, {id, value, lock}).

-define(name, governance).


genesis_state() ->
    {BlockTime, MinimumOracleTime, MaximumOracleTime} =
        case application:get_env(ae_core, test_mode, false) of
            true -> {1, 1, 1};
            false -> {297, 352, 505}
        end,
    G = [[block_reward, 1800],
         [developer_reward, 1520], 
         [time_gas, 1113],
         [space_gas, 1113],
         [max_block_size, 940],
         [create_channel_fee, 250],
         %[delete_channel_reward, 240],
         %[create_account_fee, 250],%get rid of this. we already charge a fee for making this tx.
         %[delete_account_reward, 240],%get rid of this. instead we should make the fee negative
         %[channel_rent, 600],
         %[account_rent, 600],
         [block_time, BlockTime],%remove
         [oracle_future_limit, 335],
         %[shares_conversion, 575],
         [fun_limit, 350],
         [var_limit, 600],
         [comment_limit, 137], 
         [block_creation_maturity, 100],
         [oracle_initial_liquidity, 1728],
         [minimum_oracle_time, MinimumOracleTime],
         [maximum_oracle_time, MaximumOracleTime],
         [maximum_question_size, 352],
         [block_time_after_median, 100],
         [channel_closed_time, 352],
         [question_delay, 216],
         [governance_delay, 72],
         [governance_change_limit, 51],
         [create_acc_tx, 10],
         [spend, 10],
         [delete_acc_tx, 5],
         [repo, 5],
         [nc, 10],
         [gc, 10],
         [ctc, 10],
         [cr, 5],
         [csc, 10],
         [timeout, 10],
         [cs, 10],
         [ex, 10],
         [oracle_new, 10],
         [oracle_bet, 10],
         [oracle_close, 10],
         [unmatched, 10],
         [oracle_shares, 10]],
    {ok, GenesisTree} = genesis_state(G, 1),
    GenesisTree.

genesis_state([], Tree) ->
    {ok, Tree};
genesis_state([[Name, Value] | Rest], Tree0) ->
    Id = name2number(Name),
    NewGovernance = new(Id, Value),
    Tree = write(NewGovernance, Tree0),
    genesis_state(Rest, Tree).

change(Name, Amount, Tree) ->
    {_, Gov0, _} = get(Name, Tree),
    Value0 = Gov0#gov.value + Amount,
    Value = max(Value0, 1),
    Gov = Gov0#gov{value = Value, lock = 0},
    write(Gov, Tree).
dict_lock(Name, Dict) ->
    Gov0 = dict_get(Name, Dict),
    Gov = Gov0#gov{lock = 1},
    dict_write(Gov, Dict).
dict_unlock(Name, Dict) ->
    Gov0 = dict_get(Name, Dict),
    Gov = Gov0#gov{lock = 0},
    dict_write(Gov, Dict).
    
is_locked(Gov) ->
    case Gov#gov.lock of
        0 ->
            false;
        1 ->
            true
    end.

tree_number_to_value(T) when T < 101 ->
    T;
tree_number_to_value(T) ->
    tree_number_to_value_exponential(T - 100).

tree_number_to_value_exponential(T) ->
    Top = 101,
    Bottom = 100,
    det_power(Top, Bottom, T).

det_power(Top, Bottom, T) ->
    det_power(10000, Top, Bottom, T) div 100.
det_power(Base, Top, Bottom, 1) -> 
    (Base * Top) div Bottom;
det_power(Base, Top, Bottom, T) ->
    R = T rem 2,
    case R of
        1 ->
            B2 = (Base * Top) div Bottom,
            det_power(B2, Top, Bottom, T-1);
        0 ->
            det_power(Base, (Top*Top) div Bottom, Bottom, T div 2)
    end.

serialize(Gov) ->
    <<(Gov#gov.id):8,
      (Gov#gov.value):16,
      (Gov#gov.lock):8>>.

get_value(coinbase, _) -> 0;
get_value(Name, Tree) ->
    {_, Gov, _} = get(Name, Tree),
    tree_number_to_value(Gov#gov.value).
key_to_int(X) when is_atom (X) ->
    name2number(X);
key_to_int(X) -> X.
get(Name, Tree) when is_atom(Name) ->
    case name2number(Name) of
        bad ->
            {error, unknown_name};
        Key ->
            get(Key, Tree)
    end;
get(Key, Tree) when is_integer(Key) ->
    {X, Leaf, Proof} = trie:get(Key, Tree, ?name),
    V = case Leaf of
            empty ->
                {error, empty_leaf};
            L ->
                LeafValue = leaf:value(L),
                deserialize(LeafValue)
        end,
    {X, V, Proof}.

name2number(block_reward) -> 1;
name2number(time_gas) -> 2;
name2number(space_gas) -> 27;
name2number(max_block_size) -> 3;
name2number(create_channel_fee) -> 4;
%name2number(delete_channel_reward) -> 5;
%name2number(create_account_fee) -> 6;
%name2number(delete_account_reward) -> 7;
%name2number(channel_rent) -> 9;
%name2number(account_rent) -> 10;
name2number(block_time) -> 11;
name2number(oracle_future_limit) -> 12;
name2number(shares_conversion) -> 13;
name2number(fun_limit) -> 14;
name2number(var_limit) -> 15;
name2number(comment_limit) -> 16;
name2number(block_creation_maturity) -> 17;
name2number(oracle_initial_liquidity) -> 18;
name2number(minimum_oracle_time) -> 19;
name2number(maximum_oracle_time) -> 8;
name2number(maximum_question_size) -> 20;
name2number(block_time_after_median) -> 21;
name2number(channel_closed_time) -> 22;
name2number(question_delay) -> 24;
name2number(governance_delay) -> 25;
name2number(governance_change_limit) -> 26;
name2number(create_acc_tx) -> 28;%these store the minimum fee for each transaction type. "ca" is the name of the record of the create_account_tx.
name2number(spend) -> 29;
name2number(delete_acc_tx) -> 30;
name2number(repo) -> 31;
name2number(nc) -> 32;
name2number(gc) -> 33;
name2number(ctc) -> 34;
name2number(cr) -> 35;
name2number(csc) -> 36;
name2number(timeout) -> 37;
name2number(cs) -> 38;
name2number(ex) -> 39;
name2number(oracle_new) -> 40;
name2number(oracle_bet) -> 41;
name2number(oracle_close) -> 42;
name2number(unmatched) -> 43;
name2number(oracle_shares) -> 44;
name2number(developer_reward) -> 45;
name2number(_) -> bad.
max() -> 46.
root_hash(Root) ->
    trie:root_hash(?name, Root).
make_leaf(Key, V, CFG) ->
    Key2 = if
               is_integer(Key) -> Key;
               true -> name2number(Key)
           end,
    leaf:new(Key2, V, 0, CFG).
verify_proof(RootHash, Key, Value, Proof) ->
    trees:verify_proof(?MODULE, RootHash, Key, Value, Proof).

%% Internals

%% Try to fit everything into 32-bit values
new(Id, Value) ->
    new(Id, Value, 0).
new(Id, Value, Lock) ->
    #gov{id = Id, value = Value, lock = Lock}.
dict_write(Gov, Dict) ->
    Key = Gov#gov.id,
    dict:store({governance, Key},
               serialize(Gov),
               Dict).
write(Gov, Tree) ->
    Key = Gov#gov.id,
    Serialized = serialize(Gov),
    trie:put(Key, Serialized, 0, Tree, ?name).

deserialize(SerializedGov) ->
    <<Id:8, Value:16, Lock:8>> = SerializedGov,
    #gov{id = Id, value = Value, lock = Lock}.

dict_get_value(Key, Dict) when ((Key == timeout) or (Key == delete_acc_tx)) ->
    Gov = dict_get(Key, Dict),
    V = Gov#gov.value,
    -tree_number_to_value(V);
dict_get_value(Key, Dict) ->
    Gov = dict_get(Key, Dict),
    V = Gov#gov.value,
    tree_number_to_value(V).
dict_get(Key, Dict) when is_integer(Key) ->
    deserialize(dict:fetch({governance, Key}, Dict));
dict_get(Key, Dict) ->
    deserialize(dict:fetch({governance, name2number(Key)}, Dict)).


%% Tests

test() ->
    C = new(14, 1, 0),
    {Trees, _, _} = tx_pool:data(),
    Governance = trees:governance(Trees),
    Leaf = {gov, 14, 350, 0},
    Leaf = deserialize(serialize(Leaf)),
    {_, Leaf, _} = get(fun_limit, Governance),
    G2 = write(C, Governance),
    {_, C, _} = get(fun_limit, G2),
    {Root, Leaf, Proof} = get(fun_limit, Governance),
    true = verify_proof(Root, fun_limit, serialize(Leaf), Proof),
    success.
