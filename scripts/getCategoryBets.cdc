import FlowBetPalace from 0xd19f554fdb83f838

    // This script gets recent added bets          
    pub fun main(category: String,skip: Int) :[[String]]{
                    
                
    let bets = FlowBetPalace.getCategoryBets(categoryy: category)
    
    return bets
}