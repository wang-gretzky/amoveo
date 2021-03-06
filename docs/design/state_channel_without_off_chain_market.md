# State channel without off-chain markets

Atomic swaps as invented by TierNolan are very important theoretically. https://en.bitcoin.it/wiki/Atomic_cross-chain_trading
They prove that it is possible to trustlessly exchange currency on one blockchain for currency on another.
You can use a similar mechanism to show that exchanging different currencies on the same blockchain can be trustless.

Unfortunately, atomic swaps have been worthless practically.
It only solves half the problem. We don't _just_ want to swap tokens. We want to swap them at the current market price.
So we also need a decentralized market for matching trades at a market price. The market and the atomic swap need to be trustlessly linked, otherwise the relationship can not be trust-free.

Some projects ignore this problem. They don't have off-chain markets, but they put contracts or subcurrencies into channels regardless: Raiden's "instant token swap". Bitcoin Hivemind's channels. Gnosis' channels. Aeternity's proposed state channels. Augur's use of Ox.

If you are going to trust a centralized market to give your channel the right amount of the subcurrency/contract, then there is no longer any reason to use channels. Centralized markets are already scalable. The channel is worthless in this situation.

Most state channel projects today do not put any effort into off-chain markets, because for most projects "state channel" is just a buzz word. 

Amoveo is lead by the person who invented state channels and turing complete state channels.
Amoveo will build channels right.

Discuss this on reddit https://www.reddit.com/r/Amoveo/comments/72cy4l/state_channel_without_offchain_markets_are/