# Leader Rotation

A property of any permissionless blockchain is that the entity choosing the next block is randomly selected. In proof of stake systems,
that entity is typically called the "leader" or "block producer." In Solana, we call it the leader. Under the hood, a leader is
simply a mode of the fullnode. A fullnode runs as either a leader or validator. In this chapter, we describe how a fullnode determines
what node is the leader, how that mechanism may choose different leaders at the same time, and if so, how the system converges in response.

## Leader Seed Generation

Leader scheduling is decided via a random seed.  The process is as follows:

1. Periodically, at a specific PoH tick count, select the signatures of the votes that made up the last supermajority
2. Concatenate the signatures
3. Hash the resulting string for `N` counts
4. The resulting hash is the random seed for `M` counts, `M` leader slots, where M > N

## Leader Rotation

1. The leader is chosen via a random seed generated from stake weights and votes (the leader schedule)
2. The leader is rotated every `T` PoH ticks (leader slot), according to the leader schedule
3. The schedule is applicable for `M` voting rounds

Leader's transmit for a count of `T` PoH ticks.  When `T` is reached all the validators should switch to the next scheduled leader.  To schedule leaders, the supermajority + `M` nodes are shuffled using the above calculated random seed.

All `T` ticks must be observed from the current leader for that part of PoH to be accepted by the network.  If `T` ticks (and any intervening transactions) are not observed, the network optimistically fills in the `T` ticks, and continues with PoH from the next leader.

## Partitions, Forks

Forks can arise at PoH tick counts that correspond to leader rotations, because leader nodes may or may not have observed the previous leader's data.  These empty ticks are generated by all nodes in the network at a network-specified rate for hashes-per-tick `Z`.

There are only two possible versions of the PoH during a voting round: PoH with `T` ticks and entries generated by the current leader, or PoH with just ticks.  The "just ticks" version of the PoH can be thought of as a virtual ledger, one that all nodes in the network can derive from the last tick in the previous slot.

Validators can ignore forks at other points (e.g. from the wrong leader), or slash the leader responsible for the fork.

Validators vote on the longest chain that contains their previous vote, or a longer chain if the lockout on their previous vote has expired.


#### Validator's View

##### Time Progression
The diagram below represents a validator's view of the PoH stream with possible forks over time.  L1, L2, etc. are leader slots, and `E`s represent entries from that leader during that leader's slot.  The `x`s represent ticks only, and time flows downwards in the diagram.


<img alt="Leader scheduler" src="img/leader-scheduler.svg" class="center"/>

Note that an `E` appearing on 2 branches at the same slot is a slashable condition, so a validator observing `L3` and `L3'` can slash L3 and safely choose `x` for that slot.  Once a validator observes a supermajority vote on any branch, other branches can be discarded below that tick count.  For any slot, validators need only consider a single "has entries" chain or a "ticks only" chain.

##### Time Division

It's useful to consider leader rotation over PoH tick count as time division of the job of encoding state for the network.  The following table presents the above tree of forks as a time-divided ledger.

leader slot |  L1 | L2 | L3 | L4 | L5
-------|----|----|----|----|----
data      |  E1| E2 | E3 | E4  | E5
ticks since prev  | | | | x | xx

Note that only data from leader `L3` will be accepted during leader slot
`L3`.  Data from `L3` may include "catchup" ticks back to a slot other than
`L2` if `L3` did not observe `L2`'s data.  `L4` and `L5`'s transmissions
include the "ticks since prev" PoH entries.

This arrangement of the network data streams permits nodes to save exactly this
to the ledger for replay, restart, and checkpoints.

#### Leader's View

When a new leader begins a slot, it must first transmit any PoH (ticks)
required to link the new slot with the most recently observed and voted
slot.


## Examples

### Small Partition
1. Network partition `M` occurs for 10% of the nodes
2. The larger partition `K`, with 90% of the stake weight continues to operate as
   normal
3. `M` cycles through the ranks until one of them is leader, generating ticks for
   slots where the leader is in `K`.
4. `M` validators observe 10% of the vote pool, finality is not reached.
5. `M` and `K` reconnect.
6. `M` validators cancel their votes on `M`, which has not reached finality, and
   re-cast on `K` (after their vote lockout on `M`).

### Leader Timeout
1. Next rank leader node `V` observes a timeout from current leader `A`, fills in
   `A`'s slot with virtual ticks and starts sending out entries.
2. Nodes observing both streams keep track of the forks, waiting for:
   * their vote on leader `A` to expire in order to be able to vote on `B`
   * a supermajority on `A`'s slot
3. If the first case occurs, leader `B`'s slot is filled with ticks. if the
   second case occurs, A's slot is filled with ticks
4. Partition is resolved just like in the [Small Partition](#small-parition)
   above


## Network Variables

`A` - name of a node

`B` - name of a node

`K` - number of nodes in the supermajority to whom leaders broadcast their
PoH hash for validation

`M` - number of nodes outside the supermajority to whom leaders broadcast their
PoH hash for validation

`N` - number of voting rounds for which a leader schedule is considered before
a new leader schedule is used

`T` - number of PoH ticks per leader slot (also voting round)

`V` - name of a node that will create virtual ticks

`Z` - number of hashes per PoH tick
