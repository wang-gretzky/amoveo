## Needed before launch of mainnet

* We could let the ScriptSig request as many proofs as it wants.
spk's record 'bet' should no longer have the key "prove".
script sigs should be records with 2 keys: "code" and "prove".

* We need to test the case where your channel partner deletes their account. It needs to still be possible to get your money out of the channel.

* We need to test the case where someone who is participating in the oracle deletes their own account. It needs to still be possible to bet in the oracle and close the oracle.

* grow_channel_tx:good/1 needs to be implemented

* grow_channel is bad.
To use it trustlessly, you need to make many grow_channel transaction to add a small amount of money to the channel.
We want the ability to atomically do a grow_channel transaction, and update the channel state.
So, the channel should hold one more number.
This number gets updated every time there is a grow_channel transaction for this channel.
The SPK should reference this number.
If the SPK doesn't match this number, then it is an invalid tx.
With this update, it probably becomes secure to withdraw some of the money from the channel without closing the channel.

* get rid of repetition in /apps/ae_core/src/consensus/txs/spk.erl

* We need more tests of the order book for the oracle.

* We need to make sure every time we take the hash of something, it is already a binary.
We don't want to have to reprogram term_to_binary in other languages.
all transaction types need to be serialized.
blocks need to be serialized.

* right now when we do easy:market_match it isn't updating ssme in the channels. it should.
I set it up so the contract fails until the oracle is closed. This is probably a mistake. The contract should be able to close, but with a long delay, and the money gets distributed the same was as if the oracle closed on state bad.

* review how governance locks are working. They are supposed to prevent multiple oracles updating the same governance variable simultaniously.

* trees:garbage needs to garbage collect more trees.

* review how garbage collection is working

* spk:is_improvement needs better checks. 50 CHF (paid in ETH or BTC)
Make sure delay isn't too big, and the fees aren't too high.

* we need a cron like process to match trades in the markets. It should be cautious to not match too frequently, or too infrequently.

* test mining thousands of blocks







### Things to consider doing before launch


consider reducing the block time below 10 minutes.
Then we could have faster trading in the markets.

It would be cool if we could simultaniously create an account and a channel with that account. That way users can get started faster. We would need a new transaction type. 2000 CHF

Maybe channels should be stored by hash too.

parts of the api need to be encrypted, to keep channel state private.

We need a plan on how nodes are going to sync with each other. Trying to sync with everyone simultaniously is a bad strategy.

Maybe oracles should be stored by the hash of the question. Since each question is unique.
Then how are governance oracles stored? {gov_id, oracle_height}


### Things we can do after launch of mainnet

We should optionally garbage collect old blocks, only keep the headers. 400 CHF (paid in ETH or BTC)

light nodes should only download headers and a few recent blocks. They should verify blocks in parallel.

Light nodes should garbage collect almost everything from every trie they build.

Get rid of any reference to "ae", "aeternity", and "testnet".

in the proofs dict we should have a flag for each thing to know if it has been updated. That way we can know exactly what to include in the batch update of the tree.

[AE-71] Secrets module seems unnecessary. As soon as we find out a secret, why not use arbitrage to update all the channels immediately?

[AE-72 - this should go to pre-launch list] maybe accessing the internal handler should require a signed request with a nonce.
The server should ignore commands that don't increment the nonce from last time.
alternatively, we could just turn on a firewall. This is simpler, but it has the drawback that commands on a local node have to originate from the same computer.

[DONE?] download_blocks:get_blocks should download multiple blocks at a time. 100 CHF (paid in ETH or BTC)

[DONE?] We need to test channel_solo_close and channel_slash and channel_timeout from easy. 30 CHF (paid in ETH or BTC)

[AE-74] Cold storage and tools. 150 CHF (paid in ETH or BTC)

[AE-75] Download blocks talk/1 seems useless. talker:talk is accomplishing the same goal. 40 CHF (paid in ETH or BTC)

[AE-77] Javascript light wallets need to be able to do all the channel stuff that full nodes do. 2000 CHF (paid in ETH or BTC)

[There is some sort of ranking already?] We need to update download_blocks so that peers get ranked, and we spend more time talking to higher-ranked peers.

[AE-78] It would be nice if there were some macros for chalang/src/compiler_lisp2.erl that did backtracking. that way we wouldn't have to think about control flow when making smart contracts.

[AE-79]
The current market design charges a 1/10000 fee on every trade. This is to protect from rounding errors.
There is a more elegant way to stop rounding errors. Set a certain maximum trade size. All orders must be measured in increments of the same size
A limitation of channels is that their output amounts are measured in integers from 0 to 10000.
Every 1 in G of the possible 10000 outputs can be valid.
A1 = amount of money getting matched from our bet,
A2 = amount of money in biggest possible bet,
B = A2 div 10000,
0 == A1 rem B
Making A1 rem B == 0 limits the possible output values of the contract, which slightly reduces liquidity. Being able to reduce the fee to zero is worth this small cost.

Blocks should be serialized to be fully compressed.
