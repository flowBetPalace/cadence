import FlowBetPalace from 0xd19f554fdb83f838

    // This script gets recent added bets
    pub fun main() :[[String]]{
              
          
    let bets = FlowBetPalace.getBets(amount: 2)

    return bets
}